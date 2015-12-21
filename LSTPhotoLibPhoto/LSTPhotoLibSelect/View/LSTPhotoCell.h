//
//  LSTPhotoCell.h
//  LinLi
//
//  Created by linxun on 15/12/17.
//  Copyright © 2015年 linxun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTPhotoCell : UICollectionViewCell

// 图片
@property (nonatomic, strong) UIImageView *photoImage;
// 右上角对号按钮
@property (nonatomic, strong) UIImageView *selectImage;
// 是否选中
@property (nonatomic, assign) BOOL isSelected;

@end
