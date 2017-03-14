//
//  XTSTiledImageView.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "XTSTiledImageView.h"
#import "XTSTiledLayer.h"

@interface XTSTiledImageView ()
{
    CGFloat imageScale;
    CGRect imageRect;
}

@property (retain) UIImage* image;

@end

@implementation XTSTiledImageView

+ (Class)layerClass {
    return [XTSTiledLayer class];
}

- (XTSTiledLayer*)tiledLayer
{
    return (XTSTiledLayer*)self.layer;
}

- (CGSize)tileSize
{
    return CGSizeMake(256, 256);
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.tiledLayer.levelsOfDetail = 1;
        self.tiledLayer.levelsOfDetailBias = 3;
        self.tiledLayer.tileSize = self.tileSize;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // first column|last column|first row|last row
    int f_col = floorf(CGRectGetMinX(rect) / self.tileSize.width);
    int l_col = floorf((CGRectGetMaxX(rect) - 1) / self.tileSize.width);
    int f_row = floorf(CGRectGetMinY(rect) / self.tileSize.height);
    int l_row = floorf((CGRectGetMaxY(rect) - 1) / self.tileSize.height);
    
    for (int row = f_row; row <= l_row; row++) {
        for (int col = f_col; col <= l_col; col++) {
            @autoreleasepool {
                UIImage *tile = [self.dataSource tiledImageView:self forRow:row column:col];
                if (tile) {
                    CGRect tileRect = CGRectMake(self.tileSize.width * col, self.tileSize.height * row,
                                                 self.tileSize.width, self.tileSize.height);

                    tileRect = CGRectIntersection(self.bounds, tileRect);

                    [tile drawInRect:tileRect];

                    [[UIColor whiteColor] set];
                    CGContextSetLineWidth(context, 1.0);
                    CGContextStrokeRect(context, tileRect);
                }
            }
        }
    }
}

@end
