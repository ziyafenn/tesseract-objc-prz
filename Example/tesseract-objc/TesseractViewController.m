//
//  TesseractViewController.m
//  tesseract-objc
//
//  Created by Stefan Sedlak on 12/02/2017.
//  Copyright (c) 2017 Stefan Sedlak. All rights reserved.
//

#import "TesseractViewController.h"

#import "Tesseract.h"

@interface TesseractViewController ()

@property (strong, nonatomic) Tesseract *api;
@property (weak, nonatomic) IBOutlet UILabel *recognizedL;

@end

@implementation TesseractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.api = [[Tesseract alloc] initWithLanguage:@"eng"];
}
- (IBAction)onRecognize:(UIButton *)sender {
    UIImage *image = [UIImage imageNamed:@"VALID_IMAGE"];
    NSLog(@"*** START ***");
    [self.api recognize:image
         withCompletion:^(NSString * _Nullable result) {
             NSLog(@"completion block: %@", result);
             self.recognizedL.text = result;
             NSLog(@"*** END ***");
         }
                 cancel:^BOOL(NSInteger words, NSInteger progress) {
                     NSLog(@"cancel block: words - %zd, progress - %zd", words, progress);
                     return NO;
                 }];

}

@end
