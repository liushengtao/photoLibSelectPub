//
//  LstPhotoImageView.h
//  HealthCareO2OForDemander
//
//  Created by linxun on 15/9/16.
//  Copyright (c) 2015年 vodone.com. All rights reserved.
//
//  展示选择后图片的视图

#import <UIKit/UIKit.h>

@protocol PhotoImageDelegate <NSObject>
// 删除照片
- (void)deleteImageOfImageView:(UIImageView *)imageView;
// 放大照片
- (void)zoomUpImageView:(UIImageView *)imageView;
@end

@interface LstPhotoImageView : UIImageView

@property (nonatomic, weak) id<PhotoImageDelegate>delegatePhoto;

@end
