//
//  XTSTiledImageView.h
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XTSTiledImageViewDataSource;

@interface XTSTiledImageView : UIView
@property (nonatomic, weak) id<XTSTiledImageViewDataSource> dataSource;
@end

@protocol XTSTiledImageViewDataSource <NSObject>
@required
- (UIImage *)tiledImageView:(XTSTiledImageView*)tiledImage forRow:(NSInteger)row column:(NSInteger)col;
@end
