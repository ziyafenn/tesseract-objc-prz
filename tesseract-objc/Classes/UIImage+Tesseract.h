//
//  UIImage+Tesseract.h
//  Pods
//
//  Created by Sedlak, Stefan on 12/2/17.
//

#import <UIKit/UIKit.h>

typedef struct Pix PIX;

@interface UIImage (Tesseract)

- (PIX *_Nullable)pix;

@end
