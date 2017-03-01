//
//  ViewController.m
//  XTSLargeImage
//
//  Created by linjinzhu on 2017/3/1.
//  Copyright © 2017年 linjinzhu. All rights reserved.
//

#import "ViewController.h"
#import "XTSImageScrollView.h"
#import "XTSLargeImageDownsizing.h"


@interface ViewController ()
{
    UIImage *_destImage;
}

@property (nonatomic, strong) XTSImageScrollView *scrollView;
@property (nonatomic, strong) UIImageView *progressView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    __weak __typeof(self) weakSelf = self;
    XTSLargeImageDownsizing *downsizing = [XTSLargeImageDownsizing new];
    [downsizing startDownsizingWithProgress:^(CGFloat progress, UIImage *image) {
        __strong __typeof(weakSelf) self = weakSelf;
        NSLog(@"current progress :%f", progress);
        self.progressView.image = image;

    } complete:^(UIImage *image) {
        __strong __typeof(weakSelf) self = weakSelf;
        _destImage = image;
        [self.progressView removeFromSuperview];
        self.scrollView.image = _destImage;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (XTSImageScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[XTSImageScrollView alloc] initWithFrame:self.view.bounds image:_destImage];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _progressView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_progressView];
    }

    return _progressView;
}


@end
