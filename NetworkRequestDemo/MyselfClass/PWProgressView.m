//
//  PWProgressView.m
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import "PWProgressView.h"

@interface PWProgressView ()

@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, assign) CGMutablePathRef path;
@end

@implementation PWProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _progressLayer = [CALayer layer];
        _progressLayer.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
        _progressLayer.backgroundColor = [UIColor redColor].CGColor;
        _progressLayer.borderColor = [UIColor darkGrayColor].CGColor;
        _progressLayer.borderWidth = 0.1f;
        
        [self.layer addSublayer:_progressLayer];
        
    }
    return self;
}

- (void)setProgress:(float)progress animated:(BOOL)animated {

    if (animated) {
        
        [UIView animateWithDuration:1 animations:^{
            _progressLayer.frame = CGRectMake(0, 0, progress * self.bounds.size.width, self.bounds.size.height);
        }];
    }
    else {
    
        _progressLayer.frame = CGRectMake(0, 0, progress * self.bounds.size.width, self.bounds.size.height);
    }
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressLayer.backgroundColor = progressColor.CGColor;
}
- (void)setStackColor:(UIColor *)stackColor {
    self.backgroundColor = stackColor;
}
@end
