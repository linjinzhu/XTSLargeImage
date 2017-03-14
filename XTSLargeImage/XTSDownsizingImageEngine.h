//
//  XTSDownsizingImageEngine.h
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/11.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const XTSTileInfoTileSize;
extern NSString *const XTSTileInfoMaxRow;
extern NSString *const XTSTileInfoMaxColumn;
extern NSString *const XTSTileInfoSourcePath;

typedef void (^XTSDownsizingImageEngineComplete) (NSDictionary *tileInfo, NSError *error);

@interface XTSDownsizingImageEngine : NSObject

- (void)startDownsizingImageWithPath:(NSString*)source
                            tileSize:(CGSize)tileSize
                            complete:(XTSDownsizingImageEngineComplete)complete;

+ (NSDictionary *)tileInfo;
+ (NSString *)tiledImageNameAtLocation:(CGPoint)location;
+ (NSString *)documentPath;
@end
