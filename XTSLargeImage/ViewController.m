//
//  ViewController.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "ViewController.h"
#import "XTSDownsizingImageEngine.h"
#import "XTSTiledImageView.h"

#define LargeImageSize CGSizeMake(17000, 6375)

@interface ViewController () <CALayerDelegate, XTSTiledImageViewDataSource, UIScrollViewDelegate>
{
    XTSTiledImageView *_tiledImageView;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![XTSDownsizingImageEngine tileInfo]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            XTSDownsizingImageEngine *downsizingImageEngine = [[XTSDownsizingImageEngine alloc] init];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"large_image" ofType:@"jpg"];
            CGSize tileSize = CGSizeMake(256, 256);
            XTSDownsizingImageEngineComplete complete = ^(NSDictionary *tileInfo, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUI];
                });
            };
            
            [downsizingImageEngine startDownsizingImageWithPath:path tileSize:tileSize complete:complete];
        });
    }
    
    [self setupUI];
}

- (void)setupUI
{
    self.scrollView.contentSize = LargeImageSize;
    CGFloat zoomScale = self.scrollView.contentSize.height / self.view.bounds.size.height;
    self.scrollView.minimumZoomScale = 1.0 / zoomScale;
    self.scrollView.zoomScale = 1.0 / zoomScale;
    [self tiledImageView];
}

- (void)updateUI
{
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    
    [_tiledImageView removeFromSuperview];
    _tiledImageView = nil;
    
    [self setupUI];
    
}

- (XTSTiledImageView *)tiledImageView
{
    if (!_tiledImageView) {
        CGRect frame = {CGPointZero, LargeImageSize};
        _tiledImageView = [[XTSTiledImageView alloc] initWithFrame:frame];
        _tiledImageView.dataSource = self;
        [self.scrollView addSubview:_tiledImageView];
    }
    return _tiledImageView;
}

- (UIImage *)tiledImageView:(XTSTiledImageView*)tiledImage forRow:(NSInteger)row column:(NSInteger)col
{
    NSString *imageName = [XTSDownsizingImageEngine tiledImageNameAtLocation:CGPointMake(col, row)];
    NSString *imagePath = [[XTSDownsizingImageEngine documentPath] stringByAppendingPathComponent:imageName];
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.tiledImageView;
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.maximumZoomScale = 5.0f;
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.backgroundColor = [UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:1.0f];
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

@end
