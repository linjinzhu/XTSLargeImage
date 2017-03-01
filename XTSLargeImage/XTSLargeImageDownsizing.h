//
//  XTSLargeImageDownsizing.h
//  LargeImageDownsizing
//
//  Created by linjinzhu on 2017/3/1.
//
//

#import <Foundation/Foundation.h>

typedef void (^XTSLargeImageDownsizingProgressHandler)(CGFloat progress, UIImage *image);
typedef void (^XTSLargeImageDownsizingCompleteHandler)(UIImage *image);

@interface XTSLargeImageDownsizing : NSObject
- (void)startDownsizingWithProgress:(XTSLargeImageDownsizingProgressHandler)progress
                           complete:(XTSLargeImageDownsizingCompleteHandler)complete;
@end
