//
//  PWProgressView.h
//  DownloadFileDemo
//
//  Created by ZHENGBO on 15/1/5.
//  Copyright (c) 2015年 WeiPengwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PWProgressView : UIView

@property (nonatomic, strong)UIColor *progressColor;
@property (nonatomic, strong)UIColor *stackColor;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setProgress:(float)progress animated:(BOOL)animated;
@end
