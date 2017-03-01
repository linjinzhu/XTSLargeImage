//
//  XTSTiledImageView.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "XTSTiledImageView.h"

@interface XTSTiledImageView ()
{
    CGFloat imageScale;
    CGRect imageRect;
}

@property (retain) UIImage* image;

@end

@implementation XTSTiledImageView

+ (Class)layerClass {
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame image:(UIImage*)img scale:(CGFloat)scale {
    if ((self = [super initWithFrame:frame])) {
        self.image = img;
        imageRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(_image.CGImage), CGImageGetHeight(_image.CGImage));
        imageScale = scale;
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        tiledLayer.levelsOfDetail = 4;
        tiledLayer.levelsOfDetailBias = 4;
        tiledLayer.tileSize = CGSizeMake(512.0, 512.0);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Scale the context so that the image is rendered
    // at the correct size for the zoom level.
    CGContextScaleCTM(context, imageScale,imageScale);
    CGContextDrawImage(context, imageRect, _image.CGImage);
    CGContextRestoreGState(context);	
}

@end
