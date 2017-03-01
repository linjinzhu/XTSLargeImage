//
//  XTSImageScrollView.h
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTSTiledImageView;

@interface XTSImageScrollView : UIScrollView

@property (retain) UIImage* image;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@end
