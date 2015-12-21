//
//  ViewController.m
//  LSTPhotoLibPhoto
//
//  Created by linxun on 15/12/21.
//  Copyright © 2015年 LST. All rights reserved.
//

#define kImageNum 4 // 每行显示的图片数量
#define kMargin 10.0 // 每张图片的上下左右的边距
#define kViewTopmargin 100.0 // 所有图片最上部分距离
#define kAddPhotoImage @"4_btn_add_pictures"

#import "ViewController.h"
#import "LSTPhotoLibraryController.h"
#import "LstPhotoImageView.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoImageDelegate>
{
    UIButton *_cameraBtn; // 拍照按钮
    NSMutableArray *_images; // 装载图片imageView的数组
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _images = [NSMutableArray array];
    // 初始化界面信息
    [self initViews];
}

#pragma mark 初始化界面信息
- (void)initViews
{
    // 添加上传图片按钮
    CGFloat imageW = (self.view.frame.size.width - kMargin * (kImageNum + 1)) / kImageNum;
    UIButton *camerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerBtn setFrame:CGRectMake(kMargin, kMargin + kViewTopmargin, imageW, imageW)];
    [camerBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _cameraBtn = camerBtn;
    _cameraBtn.tag = 1;
    [_cameraBtn setBackgroundImage:[UIImage imageNamed:kAddPhotoImage] forState:UIControlStateNormal];
    [self.view addSubview:camerBtn];
}

#pragma mark 添加图片按钮点击事件
- (void)cameraBtnClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@" 取消按钮点击事件 ");
    }];
    UIAlertAction *camer = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
            // 拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }];
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"从相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 从相册选取
        //            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        LSTPhotoLibraryController *controller = [[LSTPhotoLibraryController alloc] init];
        controller.hasSelectNumber = _images.count;
        controller.selectImagesBlock = ^(NSArray *images){
            for (int i = 0; i < images.count; i++) {
                [self handleImage:images[i]];
            }
        };
        controller.title = @"相机胶卷";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    [alert addAction:cancle];
    [alert addAction:camer];
    [alert addAction:photo];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 处理获取到的照片
- (void)handleImage:(UIImage *)image
{
    CGFloat size = (self.view.frame.size.width - kMargin * (kImageNum + 1)) / kImageNum;
    CGFloat i = _cameraBtn.tag; // 从1到4
    CGFloat x = kMargin + (i - 1) * (size + kMargin);
    LstPhotoImageView *imageView = [[LstPhotoImageView alloc] initWithFrame:CGRectMake(x, kMargin + kViewTopmargin, size, size)];
    imageView.delegatePhoto = self;
    [self.view addSubview:imageView];
    [imageView setImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.clipsToBounds = YES;
    imageView.tag = i + 100;
    
    // 移动button的位置
    CGRect frame = _cameraBtn.frame;
    frame.origin.x = i * (size + kMargin) + kMargin;
    _cameraBtn.frame = frame;
    _cameraBtn.tag = _cameraBtn.tag + 1;
    //    NSLog(@"++++%d", _cameraBtn.tag);
    if (_cameraBtn.tag == 5) {
        _cameraBtn.hidden = YES;
    }
    
    [_images addObject:imageView];
}

#pragma mark 删除照片代理
- (void)deleteImageOfImageView:(UIImageView *)imageView
{
    //    CGFloat distant = (self.view.width - 30.0 - imageView.size.width * 4) / 3.0;
    _cameraBtn.hidden = NO;
    _cameraBtn.tag = _cameraBtn.tag - 1;
    //    imageView.tag 从101 到 104 这里需要显示button
    NSInteger i = imageView.tag - 101;
    [_images removeObjectAtIndex:i];
    for (int i = 0; i < _images.count; i++) {
        LstPhotoImageView *imageView = _images[i];
        CGRect frame = imageView.frame;
        frame.origin.x = kMargin + i * (frame.size.width + kMargin);
        imageView.frame = frame;
        imageView.tag = i + 101;
    }
    // 设置相机按钮的位置
    CGRect cameraFrame = _cameraBtn.frame;
    cameraFrame.origin.x = cameraFrame.origin.x - kMargin - cameraFrame.size.width;
    _cameraBtn.frame = cameraFrame;
    [imageView removeFromSuperview];
}

#pragma mark UIImagePickerControllerDelegate
// 获取到照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 保存拍照照片到手机
    //    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    //        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    //    } else {
    // 这个是获取编辑的图片
    //        image = [info objectForKey:UIImagePickerControllerEditedImage];
    //    }
    // 处理图片
    [self handleImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
// 点击取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        //        [LLProgressHUD showError:Internation(@"943") duration:2];
        //        ALog(@"%@", error.localizedDescription);
    } else {
        // 成功保存到相册
        //        [LLProgressHUD showSuccess:Internation(@"942") duration:2];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
