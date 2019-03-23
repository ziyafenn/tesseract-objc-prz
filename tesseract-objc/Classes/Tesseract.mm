//
//  Tesseract.m
//  tesseract-objc
//
//  Created by Sedlak, Stefan on 12/2/17.
//

#import "Tesseract.h"

#import <baseapi.h>
#import <ocrclass.h>

#import "UIImage+Tesseract.h"

typedef BOOL (^cancel_block_t)(NSInteger words);

bool cancel_func(void *context, int words) {
    cancel_block_t cancel_block = (__bridge typeof(cancel_block_t))context;
    bool shall_cancel = (bool)cancel_block(words);
    return shall_cancel;
}
bool progress_func(int progress, int left, int right, int top, int bottom) {
    NSLog(@"progress: %zd, (%zd, %zd, %zd, %zd)", progress, left, right, top, bottom);
    return true;
}

@interface Tesseract () {
    tesseract::TessBaseAPI *_tesseract;
    ETEXT_DESC *_monitor;
}

@property (strong, nonatomic, nonnull) NSString *language;
@property (strong, nonatomic, nullable) NSString *dataPath;

@end

@implementation Tesseract

- (instancetype)init
{
    self = [self initWithLanguage:@"eng" andPath:nil];
    return self;
}

- (instancetype)initWithLanguage:(NSString *_Nonnull)language {
    self = [self initWithLanguage:language andPath:nil];
    return self;
}

- (instancetype _Nonnull)initWithLanguage:(NSString *_Nonnull)language
                                  andPath:(NSString *_Nullable)path
{
    self = [super init];
    if (self) {
        _tesseract = nullptr;
        _monitor = nullptr;
        self.language = language ?: @"eng";
        self.dataPath = path ?: [self defaultPath];
    }
    return self;
}

- (void)dealloc {
    NSAssert(_monitor == nil, @"Recognition already in progress.");
    delete _tesseract; _tesseract = nullptr;
}

- (nullable NSString *)defaultPath
{
    NSString *language = self.language;
    if (!language) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleName = [NSString stringWithFormat:@"tesseract-%@", language];
    NSString *path = [bundle pathForResource:bundleName ofType:@"bundle"];
    return path;
}

- (BOOL)recognize:(UIImage *_Nonnull)image
   withCompletion:(void (^_Nonnull)(NSString *_Nullable result))completionBlock
           cancel:(BOOL (^_Nullable)(NSInteger words, NSInteger progress))cancelBlock
{
    if (!image || !completionBlock || !self.dataPath) {
        return NO;
    }
    @synchronized(self) {
        if (_monitor) {
            NSLog(@"Recognition already in progress.");
            return NO;
        }
        _monitor = new ETEXT_DESC();
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block NSString *result = nil;
        
        int initResult = [self initializeTesseract];
        if (initResult != EXIT_SUCCESS) {
            @synchronized(self) {
                delete _monitor; _monitor = nullptr;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(result);
            });
            return;
        }
        
        _monitor->set_deadline_msecs(1000); // TODO: use param
        _monitor->cancel = cancel_func;
        _monitor->cancel_this = (__bridge_retained void *)^BOOL(NSInteger words) {
            if (_monitor->ocr_alive) {
                _monitor->ocr_alive = 0;
            }
            NSInteger progress = (NSInteger)_monitor->progress;
            BOOL shallCancel = cancelBlock ? cancelBlock(words, progress) : NO;
            return shallCancel;
        };
#if DEBUG
        _monitor->progress_callback = progress_func;
#endif

        @try {
            PIX *pix = [image pix];
            if (pix) {
                _tesseract->SetImage(pix);
                int recognitionResult = _tesseract->Recognize(_monitor);
                if (recognitionResult == EXIT_SUCCESS) {
                    char *text = _tesseract->GetUTF8Text();
                    result = [NSString stringWithUTF8String:text];
                    delete[] text;
                } else if (_monitor->deadline_exceeded()) {
                    NSLog(@"recognition deadline was exceeded");
                }
            } else {
                NSLog(@"Pixmap was not created.");
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception was raised while recognizing: %@", exception);
        }
        // do not remove cancel_release - it releases cancel_block. It would cause Tesseract instance unreleased.
        cancel_block_t cancel_release __attribute__((unused)) = (__bridge_transfer cancel_block_t)(_monitor->cancel_this);
        @synchronized(self) {
            delete _monitor; _monitor = nullptr;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(result);
        });
    });
    return YES;
}

- (int)initializeTesseract {
    @synchronized(self) {
        if (_tesseract) {
            return EXIT_SUCCESS;
        }
        tesseract::TessBaseAPI *tesseract = new tesseract::TessBaseAPI();
        int result = tesseract->Init(self.dataPath.UTF8String, self.language.UTF8String);
        if (result == EXIT_SUCCESS) {
            _tesseract = tesseract;
            tesseract -> SetVariable([@"tessedit_char_whitelist" cStringUsingEncoding:NSASCIIStringEncoding], [@"1234567890/." cStringUsingEncoding:NSASCIIStringEncoding]);
        } else {
            NSLog(@"Tesseract initialization has failed.");
            delete tesseract; tesseract = nullptr;
        }
        return result;
    }
}

@end
