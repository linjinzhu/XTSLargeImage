//
//  XTSDownsizingImageEngine.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/11.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "XTSDownsizingImageEngine.h"

NSString *const XTSTileInfoTileSize = @"XTSTileInfoTileSize";
NSString *const XTSTileInfoMaxRow = @"XTSTileInfoMaxRow";
NSString *const XTSTileInfoMaxColumn = @"XTSTileInfoMaxColumn";
NSString *const XTSTileInfoSourcePath = @"XTSTileInfoSourcePath";
NSString *const XTSTileInfoFileName = @"tileinfo.plist";

NSString *const XTSTileImageNameFormat = @"tileImage_%ld_%ld.png";
const CGFloat XTSTileImageSize = 256;

@implementation XTSDownsizingImageEngine
- (void)startDownsizingImageWithPath:(NSString*)source
                            tileSize:(CGSize)tileSize
                            complete:(XTSDownsizingImageEngineComplete)complete
{
    NSError *error = nil;
    NSMutableDictionary *tileInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    do {
        if (source.length == 0u) {
            error = [self.class errorWithMsg:@"source image can't be nil." code:0];
            break;
        }
        [tileInfo setObject:source forKey:XTSTileInfoSourcePath];
        
        if (CGSizeEqualToSize(tileSize, CGSizeZero)) {
            tileSize = CGSizeMake(XTSTileImageSize, XTSTileImageSize);
        }
        [tileInfo setObject:[NSValue valueWithCGSize:tileSize] forKey:XTSTileInfoTileSize];
        
        //1.加载图片
        UIImage *sourceImage = [[UIImage alloc] initWithContentsOfFile:source];
        CGSize size = sourceImage.size;
        CGImageRef imageRef = [sourceImage CGImage];
        
        //2.计算行和列
        NSInteger cols = ceil(size.width / tileSize.width);
        NSInteger rows = ceil(size.height / tileSize.height);
        [tileInfo setObject:@(rows) forKey:XTSTileInfoMaxRow];
        [tileInfo setObject:@(cols) forKey:XTSTileInfoMaxColumn];
        
        //3.生成瓦片
        for (NSInteger row = 0; row < rows; row++) {
            for (NSInteger col = 0; col < cols; col++) {
                @autoreleasepool {
                    //计算坐标
                    CGPoint origin = CGPointMake(col * tileSize.width, row * tileSize.height);
                    CGRect rect = {origin, tileSize};
                    //生成图片
                    CGImageRef tileImageRef = CGImageCreateWithImageInRect(imageRef, rect);
                    UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
                    NSData *imageData = UIImagePNGRepresentation(tileImage);
                    //保存图片
                    NSString *fileName = [self.class tiledImageNameAtLocation:CGPointMake(col, row)];
                    NSString *path = [[self.class documentPath] stringByAppendingPathComponent:fileName];
                    BOOL suc = [imageData writeToFile:path atomically:YES];
                    if (!suc) {
                        error = [self.class errorWithMsg:@"" code:0];
                        break;
                    }                    
                }
            }
        }
    } while (0);
    
    if (complete != nil) {
        complete(tileInfo, error);
    }
    
    [self.class setTileInfo:tileInfo];
}

+ (NSString *)tiledImageNameAtLocation:(CGPoint)location
{
    return [NSString stringWithFormat:XTSTileImageNameFormat, (NSInteger)location.x, (NSInteger)location.y];
}

+ (NSString *)documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSError *)errorWithMsg:(NSString*)msg code:(NSInteger)code
{
    if (msg.length == 0u) {
        return nil;
    }
    
    NSString *domain = @"com.xtools.largeimage.downsizingengine";
    NSError *error = [NSError errorWithDomain:domain code:code userInfo:@{NSLocalizedDescriptionKey:msg}];
    return error;
}

+ (NSString*)defaultTileImageNameFormat
{
    return XTSTileImageNameFormat;
}

+ (NSDictionary *)tileInfo
{
    NSString *file = [[self.class documentPath] stringByAppendingPathComponent:XTSTileInfoFileName];
    return [NSDictionary dictionaryWithContentsOfFile:file];
}

+ (void)setTileInfo:(NSDictionary *)tileInfo
{
    if (tileInfo.count > 0u) {
        NSString *file = [[self.class documentPath] stringByAppendingPathComponent:XTSTileInfoFileName];
        if ([tileInfo writeToFile:file atomically:YES]) NSLog(@"save tile info errored.");
    }
}

@end
