//
//  LSTPhotoLibraryController.h
//  LinLi
//
//  Created by linxun on 15/12/17.
//  Copyright © 2015年 linxun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectImages)(NSArray *images);

@interface LSTPhotoLibraryController : UIViewController

@property (nonatomic, copy)selectImages selectImagesBlock;
@property (nonatomic, assign) CGFloat hasSelectNumber; // 已经选择的照片数量

@end
