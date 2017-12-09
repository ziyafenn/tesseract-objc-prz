//
//  Tesseract.h
//  tesseract-objc
//
//  Created by Sedlak, Stefan on 12/2/17.
//

#import <Foundation/Foundation.h>

/*!
 * @class Tesseract
 * @discussion Tesseract class wrappes `tesstesseract::TessBaseAPI`. It allows to run recognition. It is possible to run only 1 recognition at a time. Version of Tesseract engine is the latest stable release: 3.05.01.
 */
@interface Tesseract : NSObject

/*!
 Initializer for languages provided by subspec.
 @param language name according ISO 639-3 standard
 */
- (instancetype _Nonnull)initWithLanguage:(NSString *_Nonnull)language;
/*!
 Initializer for custom data.
 @param language name according ISO 639-3 standard
 @param path must contain directory 'tessdata' with trained data file named {language}.traineddata For example 'tessdata/eng.traineddata' for parameter language value 'eng'
 */
- (instancetype _Nonnull)initWithLanguage:(NSString *_Nonnull)language
                                  andPath:(NSString *_Nullable)path;
/*!
 Recognition method. First recognition initializes Tesseract engine. Engine initialization takes less than 1s (depends on trained data). Next recognition is quicker.  Default recognition timeout is set to 1s.
 @param image to be recogized
 @param completionBlock to provide result of recognition. Param result is nil in case of error. If no text was recognized result is empty string. completionBlock is always triggered on main queue.
 @param cancelBlock allows to cancel recognition when block returns YES. It is triggered on background queue.
 @return value indicating if image was queued for recognition. In case of recognition in progress it returns NO.
 */
- (BOOL)recognize:(UIImage *_Nonnull)image
   withCompletion:(void (^_Nonnull)(NSString *_Nullable result))completionBlock
           cancel:(BOOL (^_Nullable)(NSInteger words, NSInteger progress))cancelBlock;

@end
