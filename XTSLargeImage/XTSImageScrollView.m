//
//  XTSImageScrollView.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "XTSImageScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "XTSTiledImageView.h"

@interface XTSImageScrollView () <UIScrollViewDelegate>
{
    XTSTiledImageView* frontTiledView;

    UIImageView *backgroundImageView;
    float minimumScale;

    CGFloat imageScale;
}

@property (retain) XTSTiledImageView* backTiledView;
@end

@implementation XTSImageScrollView

-(id)initWithFrame:(CGRect)frame image:(UIImage*)img {
    if((self = [super initWithFrame:frame])) {
        // Set up the UIScrollView
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.maximumZoomScale = 5.0f;
        self.minimumZoomScale = 0.25f;
        self.backgroundColor = [UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:1.0f];
        // determine the size of the image
        self.image = img;
        CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(_image.CGImage),CGImageGetHeight(_image.CGImage));
        imageScale = self.frame.size.width/imageRect.size.width;
        minimumScale = imageScale * 0.75f;
        NSLog(@"imageScale: %f",imageScale);
        imageRect.size = CGSizeMake(imageRect.size.width*imageScale, imageRect.size.height*imageScale);
        // Create a low res image representation of the image to display before the TiledImageView
        // renders its content.
        UIGraphicsBeginImageContext(imageRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextDrawImage(context, imageRect, _image.CGImage);
        CGContextRestoreGState(context);
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = imageRect;
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundImageView];
        [self sendSubviewToBack:backgroundImageView];
        // Create the TiledImageView based on the size of the image and scale it to fit the view.
        frontTiledView = [[XTSTiledImageView alloc] initWithFrame:imageRect image:_image scale:imageScale];
        [self addSubview:frontTiledView];
    }
    return self;
}

#pragma mark -
#pragma mark Override layoutSubviews to center content
- (void)layoutSubviews {
    [super layoutSubviews];
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = frontTiledView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    frontTiledView.frame = frameToCenter;
    backgroundImageView.frame = frameToCenter;
    // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
    // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
    // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
    frontTiledView.contentScaleFactor = 1.0;
}
#pragma mark -
#pragma mark UIScrollView delegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return frontTiledView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    imageScale *=scale;
    if( imageScale < minimumScale ) imageScale = minimumScale;
    CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(_image.CGImage) * imageScale,CGImageGetHeight(_image.CGImage) * imageScale);
    frontTiledView = [[XTSTiledImageView alloc] initWithFrame:imageRect image:_image scale:imageScale];
    [self addSubview:frontTiledView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    [_backTiledView removeFromSuperview];
    self.backTiledView = frontTiledView;
}


@end
