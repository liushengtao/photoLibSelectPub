//
//  LstPhotoImageView.m
//  HealthCareO2OForDemander
//
//  Created by linxun on 15/9/16.
//  Copyright (c) 2015年 vodone.com. All rights reserved.
//

#define kImageDelete @"Lst9_icon_delete" // 删除图片按钮
#import "LstPhotoImageView.h"

@implementation LstPhotoImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 初始化视图
        [self initViewsWithFrame:frame];
    }
    
    return self;
}

#pragma mark 初始化视图
- (void)initViewsWithFrame:(CGRect)frame
{
    self.userInteractionEnabled = YES;
    // 添加手势可以放大
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self addGestureRecognizer:tap];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setFrame:CGRectMake(frame.size.width - 20, 0, 20, 20)];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:kImageDelete] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(delegateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:deleteBtn];
}

#pragma mark 点击图片
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    if ([self.delegatePhoto respondsToSelector:@selector(zoomUpImageView:)]) {
        [self.delegatePhoto zoomUpImageView:imageView];
    }
}

#pragma mark 删除按钮点击事件
- (void)delegateBtnClick
{
    if ([self.delegatePhoto respondsToSelector:@selector(deleteImageOfImageView:)]) {
        [self.delegatePhoto deleteImageOfImageView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
