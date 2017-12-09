//
//  TesseractTests.m
//  Tesseract class tests
//
//  Created by Stefan Sedlak on 12/02/2017.
//  Copyright (c) 2017 Stefan Sedlak. All rights reserved.
//

@import XCTest;
@import Tesseract;

@interface TesseractTests : XCTestCase
@end

@implementation TesseractTests

- (void)testRecognition
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);

    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    XCTestExpectation *cancelExpectation = [self expectationWithDescription:@"cancel shall be called several times"];
    cancelExpectation.assertForOverFulfill = NO;
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"NL22FRBK0291015897\n\n");
        [completionExpectation fulfill];
    } cancel:^BOOL(NSInteger words, NSInteger progress) {
        [cancelExpectation fulfill];
        return NO;
    }];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionCustomData
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"Frameworks/Tesseract.framework/tesseract-eng.bundle"];
    XCTAssertNotNil(path);
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng" andPath:path];
    XCTAssertNotNil(tesseract);

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"NL22FRBK0291015897\n\n");
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionNoCancelBlock
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"NL22FRBK0291015897\n\n");
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionCanceled
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    XCTestExpectation *cancelExpectation = [self expectationWithDescription:@"cancel shall be called"];
    
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertNil(result);
        [completionExpectation fulfill];
    } cancel:^BOOL(NSInteger words, NSInteger progress) {
        [cancelExpectation fulfill];
        return YES;
    }];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionFailedInvalidCustomDataLanguage
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    NSString *path = [NSBundle mainBundle].bundlePath;
    path = [path stringByAppendingPathComponent:@"Frameworks/Tesseract.framework/tesseract-eng.bundle"];
    XCTAssertNotNil(path);

    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"INVALID_LANG" andPath:path];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertNil(result);
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionFailedInvalidCustomDataPath
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng" andPath:@"INVALID_PATH"];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertNil(result);
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRecognitionFailedTimeout
{
    UIImage *image = [UIImage imageNamed:@"HUGE_IMAGE"];
    XCTAssertNotNil(image);
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertNil(result);
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(isQueued);
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testRefuseRecognitionNoImage
{
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);

    UIImage *image = [UIImage imageNamed:@"NON_EXISTING_IMAGE"];
    XCTAssertNil(image);

    BOOL isQueued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTFail(@"shall not happen as it was not queued");
    } cancel:nil];
    XCTAssertFalse(isQueued);
}

- (void)testRefuseRecognitionNoCompletion
{
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    void (^completionBlock)(NSString *) = nil;
    BOOL isQueued = [tesseract recognize:image withCompletion:completionBlock cancel:nil];
    XCTAssertFalse(isQueued);
}

- (void)testRefuseParallelRecognition
{
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    XCTAssertNotNil(image);
    
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    XCTAssertNotNil(tesseract);
    
    // 1st recognition shall be finished
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion shall be always called"];
    BOOL is1Queued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTAssertEqualObjects(result, @"NL22FRBK0291015897\n\n");
        [completionExpectation fulfill];
    } cancel:nil];
    XCTAssertTrue(is1Queued);
    
    // 2nd / parallel recognition shall not start
    BOOL is2Queued = [tesseract recognize:image withCompletion:^(NSString * _Nullable result) {
        XCTFail(@"shall not happen as recognition shall not be queued");
    } cancel:nil];
    XCTAssertFalse(is2Queued);

    [self waitForExpectationsWithTimeout:1 handler:nil];
}


@end

