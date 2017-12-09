//
//  UIImage+Tesseract.m
//  Pods
//
//  Created by Sedlak, Stefan on 12/2/17.
//

#import "UIImage+Tesseract.h"

#import <allheaders.h>

typedef void(*pix_copy_func)(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset);

void copy_block_8(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset) {
    SET_DATA_BYTE(toAddr, toOffset, fromAddr[fromOffset]);
}
void copy_block_32(l_uint32 *toAddr, NSUInteger toOffset, const UInt8 *fromAddr, NSUInteger fromOffset) {
    toAddr[toOffset] = (fromAddr[fromOffset] << 24) | (fromAddr[fromOffset + 1] << 16) |
    (fromAddr[fromOffset + 2] << 8) | fromAddr[fromOffset + 3];
}

@implementation UIImage (Tesseract)

- (PIX *_Nullable)pix
{
    l_int32 width = self.size.width;
    l_int32 height = self.size.height;
    
    CGImage *cgImage = self.CGImage;
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const UInt8 *pixels = CFDataGetBytePtr(imageData);
    
    size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
    size_t bytesPerPixel = bitsPerPixel / CHAR_BIT;
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    
    size_t bpp = MAX(1, bitsPerPixel);
    
    pix_copy_func copy_block = NULL;
    switch (bpp) {
        case 8: {
            copy_block = copy_block_8;
            break;
        }
        case 32: {
            copy_block = copy_block_32;
            break;
        }
        default: {
            NSLog(@"Cannot convert image to Pix with bpp = %tu", bpp);
            CFRelease(imageData);
            return nil;
        }
    }

    PIX *pix = pixCreateNoInit(width, height, (l_int32)bpp);
    if (!pix) {
        NSLog(@"pixCreateNoInit has failed");
        CFRelease(imageData);
        return nil;
    }
    l_uint32 *data = pixGetData(pix);
    int wpl = pixGetWpl(pix);

    if (copy_block) {
        switch (self.imageOrientation) {
            case UIImageOrientationUp: {
                // Maintain byte order consistency across different endianness.
                for (int y = 0; y < height; ++y, pixels += bytesPerRow, data += wpl) {
                    for (int x = 0; x < width; ++x) {
                        copy_block(data, x, pixels, x * bytesPerPixel);
                    }
                }
                break;
            }
            case UIImageOrientationUpMirrored: {
                // Maintain byte order consistency across different endianness.
                for (int y = 0; y < height; ++y, pixels += bytesPerRow, data += wpl) {
                    int maxX = width - 1;
                    for (int x = maxX; x >= 0; --x) {
                        copy_block(data, maxX - x, pixels, x * bytesPerPixel);
                    }
                }
                break;
            }
            case UIImageOrientationDown: {
                // Maintain byte order consistency across different endianness.
                pixels += (height - 1) * bytesPerRow;
                for (int y = height - 1; y >= 0; --y, pixels -= bytesPerRow, data += wpl) {
                    int maxX = width - 1;
                    for (int x = maxX; x >= 0; --x) {
                        copy_block(data, maxX - x, pixels, x * bytesPerPixel);
                    }
                }
                break;
            }
            case UIImageOrientationDownMirrored: {
                // Maintain byte order consistency across different endianness.
                pixels += (height - 1) * bytesPerRow;
                for (int y = height - 1; y >= 0; --y, pixels -= bytesPerRow, data += wpl) {
                    for (int x = 0; x < width; ++x) {
                        copy_block(data, x, pixels, x * bytesPerPixel);
                    }
                }
                break;
            }
            case UIImageOrientationLeft: {
                // Maintain byte order consistency across different endianness.
                for (int x = 0; x < height; ++x, data += wpl) {
                    int maxY = width - 1;
                    for (int y = maxY; y >= 0; --y) {
                        int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
                        copy_block(data, maxY - y, pixels, x0);
                    }
                }
                break;
            }
            case UIImageOrientationLeftMirrored: {
                // Maintain byte order consistency across different endianness.
                for (int x = height - 1; x >= 0; --x, data += wpl) {
                    int maxY = width - 1;
                    for (int y = maxY; y >= 0; --y) {
                        int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
                        copy_block(data, maxY - y, pixels, x0);
                    }
                }
                break;
            }
            case UIImageOrientationRight: {
                // Maintain byte order consistency across different endianness.
                for (int x = height - 1; x >=0; --x, data += wpl) {
                    for (int y = 0; y < width; ++y) {
                        int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
                        copy_block(data, y, pixels, x0);
                    }
                }
                break;
            }
            case UIImageOrientationRightMirrored: {
                // Maintain byte order consistency across different endianness.
                for (int x = 0; x < height; ++x, data += wpl) {
                    for (int y = 0; y < width; ++y) {
                        int x0 = y * (int)bytesPerRow + x * (int)bytesPerPixel;
                        copy_block(data, y, pixels, x0);
                    }
                }
                break;
            }
            default: {
                NSLog(@"Shall not happen");
                break;
            }
        }
    }
    
    pixSetYRes(pix, self.scale * 72);
    CFRelease(imageData);
    
    return pix;
}

@end
