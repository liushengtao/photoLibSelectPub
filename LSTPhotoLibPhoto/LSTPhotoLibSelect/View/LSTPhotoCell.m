//
//  LSTPhotoCell.m
//  LinLi
//
//  Created by linxun on 15/12/17.
//  Copyright © 2015年 linxun.com. All rights reserved.
//

#define kMargin 2.5 // image距离四周的距离
#import "LSTPhotoCell.h"

@implementation LSTPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 初始化一些基本视图
        [self initViews];
    }
    
    return self;
}

#pragma mark 初始化一些基本视图
- (void)initViews
{
    self.backgroundColor = [UIColor whiteColor];
    // 图片
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.photoImage = [[UIImageView alloc] init];
    [self.photoImage setFrame:CGRectMake(kMargin, kMargin, width - 2 * kMargin, height - 2 * kMargin)];
    self.photoImage.userInteractionEnabled = YES;
    [self addSubview:self.photoImage];
    
    // 选择按钮
    self.selectImage = [[UIImageView alloc] init];
    [self.selectImage setFrame: CGRectMake(width - 2 * kMargin - 24, 2 * kMargin, 24, 24)];
    self.selectImage.userInteractionEnabled = YES;
    [self.selectImage setImage:[UIImage imageNamed:@"LST7_icon_selected_s"]];
    [self addSubview:self.selectImage];
    
}

//- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
//    CGFloat width = self.frame.size.width;
//    CGFloat height = self.frame.size.height;
//    [self.photoImage setFrame:CGRectMake(kMargin, kMargin, width - 2 * kMargin, height - 2 * kMargin)];
//    [self.selectImage setFrame: CGRectMake(width - 2 * kMargin - 24, 2 * kMargin, 24, 24)];
//}

@end
