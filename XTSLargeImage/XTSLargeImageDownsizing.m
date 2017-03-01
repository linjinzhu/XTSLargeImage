//
//  XTSLargeImageDownsizing.m
//  LargeImageDownsizing
//
//  Created by linjinzhu on 2017/3/1.
//
//

#import "XTSLargeImageDownsizing.h"
#define kImageFilename @"large_image.jpg"

#define kDestImageSizeMB 60.0f // 输出图片大小 (x)MB
#define kSourceImageTileSizeMB 20.0f // 原始图片瓦片大小 (x)MB
#define bytesPerMB 1048576.0f
#define bytesPerPixel 4.0f
#define pixelsPerMB ( bytesPerMB / bytesPerPixel )
#define destTotalPixels kDestImageSizeMB * pixelsPerMB
#define tileTotalPixels kSourceImageTileSizeMB * pixelsPerMB
#define destSeemOverlap 2.0f // 瓦片间重叠的像素数

@interface XTSLargeImageDownsizing ()
{
    // 原始图片
    UIImage* sourceImage;
    // 输出图片
    UIImage* destImage;
    // 每次加载到内存的最大像素数在原始图片上的区域
    CGRect sourceTile;
    // 输出图片最大像素数，在输出图片上的区域，在sourceTile基础上等比缩放
    CGRect destTile;
    // 输出和输入图片的像素例
    float imageScale;
    // 原始图片的分辨率
    CGSize sourceResolution;
    // 原始图片总像素数
    float sourceTotalPixels;
    // 原始图片总大小
    float sourceTotalMB;
    // output image width and height
    // 输出图片的分辨率
    CGSize destResolution;
    // 用于渲染输出图片的上下文
    CGContextRef destContext;
    // 重叠像素数
    float sourceSeemOverlap;
}

@property (nonatomic, copy) XTSLargeImageDownsizingProgressHandler progress;
@property (nonatomic, copy) XTSLargeImageDownsizingCompleteHandler complete;
@end

@implementation XTSLargeImageDownsizing
- (void)startDownsizingWithProgress:(XTSLargeImageDownsizingProgressHandler)progress
                           complete:(XTSLargeImageDownsizingCompleteHandler)complete
{
    _progress = progress;
    _complete = complete;
    [NSThread detachNewThreadSelector:@selector(downsize:) toTarget:self withObject:nil];
}

-(void)downsize:(id)arg {
    @autoreleasepool {
        // 从文件里读取图片，此时不会从磁盘读取任何像素，真正读取像素信息是在绘制阶段
        sourceImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kImageFilename ofType:nil]];
        if( sourceImage == nil ) NSAssert(NO, @"image named `large_image.jpg` not found!!!");
        // 获取图片的高度和宽度
        sourceResolution.width = CGImageGetWidth(sourceImage.CGImage);
        sourceResolution.height = CGImageGetHeight(sourceImage.CGImage);
        // 计算输入图片包含的像素数
        sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        // 把图片存放到内存里，需要多少兆字节
        sourceTotalMB = sourceTotalPixels / pixelsPerMB;
        // 计算输出图片和原始图片缩放比
        imageScale = destTotalPixels / sourceTotalPixels;
        // 通过缩放比计算输出图片的宽高
        destResolution.width = (int)( sourceResolution.width * imageScale );
        destResolution.height = (int)( sourceResolution.height * imageScale );

        // 创建bitmap上下文来存放输出图片的像素数据
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int bytesPerRow = bytesPerPixel * destResolution.width;
        // 分配内存用于存放输出图片像素数据
        void* destBitmapData = malloc( bytesPerRow * destResolution.height );
        if( destBitmapData == NULL ) NSLog(@"failed to allocate space for the output image!");
        // 创建输出图片的图形上下文
        destContext = CGBitmapContextCreate( destBitmapData, destResolution.width, destResolution.height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast );
        if( destContext == NULL ) {
            free( destBitmapData );
            NSLog(@"failed to create the output bitmap context!");
        }

        // 释放ColorSpace
        CGColorSpaceRelease( colorSpace );
        CGContextTranslateCTM( destContext, 0.0f, destResolution.height );
        CGContextScaleCTM( destContext, 1.0f, -1.0f );

        sourceTile.size.width = sourceResolution.width;
        sourceTile.size.height = (int)( tileTotalPixels / sourceTile.size.width );
        NSLog(@"source tile size: %f x %f",sourceTile.size.width, sourceTile.size.height);
        sourceTile.origin.x = 0.0f;

        destTile.size.width = destResolution.width;
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        NSLog(@"dest tile size: %f x %f",destTile.size.width, destTile.size.height);

        sourceSeemOverlap = (int)( ( destSeemOverlap / destResolution.height ) * sourceResolution.height );
        NSLog(@"dest seem overlap: %f, source seem overlap: %f",destSeemOverlap, sourceSeemOverlap);
        CGImageRef sourceTileImageRef;
        // 计算拼接image需要读写操作的次数
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        // 不能整除，则需要再读写一次
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if( remainder ) iterations++;

        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += destSeemOverlap;
        NSLog(@"beginning downsize. iterations: %d, tile height: %f, remainder height: %d", iterations, sourceTile.size.height,remainder );
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                NSLog(@"iteration %d of %d",y+1,iterations);
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = ( destResolution.height ) - ( ( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + destSeemOverlap );
                // 创建原始图片瓦片的引用
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImage.CGImage, sourceTile );
                // 渲染最后一张瓦片
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }

                // 从原图片写入到当前图形上下文，大小是输出图片的瓦片大小
                CGContextDrawImage( destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );

                if( y < iterations - 1 ) {
                    sourceImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kImageFilename ofType:nil]];
                    [self performSelectorOnMainThread:@selector(downsizeProgress:) withObject:@((CGFloat)y/iterations) waitUntilDone:YES];
                }
            }
        }
        NSLog(@"downsize complete.");
        [self performSelectorOnMainThread:@selector(downsizeComplete:) withObject:nil waitUntilDone:YES];

        // 任务结束，释放上下文
        CGContextRelease( destContext );
    }
}

-(void)createImageFromContext {
    // 从当前图片上下文中创建CGImage
    CGImageRef destImageRef = CGBitmapContextCreateImage( destContext );
    if( destImageRef == NULL ) NSLog(@"destImageRef is null.");
    // CGImage转UIImage
    destImage = [UIImage imageWithCGImage:destImageRef scale:1.0f orientation:UIImageOrientationDownMirrored];
    // 释放CGImage
    CGImageRelease( destImageRef );
    if( destImage == nil ) NSLog(@"destImage is nil.");
}

-(void)downsizeProgress:(id)arg {
    [self createImageFromContext];
    if (_progress) {
        _progress([arg floatValue], destImage);
    }
}

-(void)downsizeComplete:(id)arg {
    [self createImageFromContext];
    if (_progress) {
        _progress(1, destImage);
    }

    if (_complete) {
        _complete(destImage);
    }
}

@end
