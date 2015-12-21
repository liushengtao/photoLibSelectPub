//
//  LSTPhotoLibraryController.m
//  LinLi
//
//  Created by linxun on 15/12/17.
//  Copyright © 2015年 linxun.com. All rights reserved.
//

#define kImageSelect @"LST7_icon_selected_S" // 选中图片
#define kImageNormal @"LST7_icon_selected_N" // 未被选中图片

#define kmargin 4.0 // UICollectionView距离四周的位置
#define kRowViewNumber 4 // 每行的数量
#define kSelectNumMax 4 // 选择的最多的照片数
#import "LSTPhotoLibraryController.h"
#import "LSTPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZXImageViewController.h"
#import "SVProgressHUD.h"

@interface LSTPhotoLibraryController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView; //
    NSMutableArray *_pohtoLibraryArray; // 存放照片model的数组
    NSMutableArray *_selectLibraryArray; // 选中的model的数组
    NSMutableArray *_selectNumbersArray; // 存放照片的indexPath数组
    ALAssetsLibrary *_assetsLibrary; //
    
    UIButton *_sureButton; // 确定button
    UIButton *_leftItemButton; // 取消按钮
}
@end

@implementation LSTPhotoLibraryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化界面
    [self initViews];
    // 加载数据
    [self loadData];
}

#pragma mark 初始化界面
- (void)initViews
{
    _selectNumbersArray = [NSMutableArray array];
    _selectLibraryArray = [NSMutableArray array];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    CGFloat tabberH = 40.0;
    // 添加UICollectionView
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height - tabberH) collectionViewLayout:flow];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[LSTPhotoCell class] forCellWithReuseIdentifier:@"LSTPhotoCell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    // 添加底部的tabbar
    UIView *tabbar = [[UIView alloc] initWithFrame:CGRectMake(0, height - tabberH, width, tabberH)];
    tabbar.backgroundColor = [UIColor colorWithRed:238.0 / 255.0 green:238.0 / 255.0 blue:238.0 / 255.0 alpha:1.0];
    [self.view addSubview:tabbar];
    // 预览
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(10.0, 0.0, 50.0, tabberH)];
    [button setTitle:@"预览" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitleColor:[UIColor colorWithRed:153.0 / 255.0 green:153.0 / 255.0 blue:153.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [tabbar addSubview:button];
    // 确定
    _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sureButton setFrame:CGRectMake(width - 70.0, 5.0, 62.0, 30.0)];
    _sureButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [_sureButton setBackgroundColor:[UIColor greenColor]];
    _sureButton.layer.cornerRadius = 5;
    _sureButton.layer.masksToBounds = YES;
    [tabbar addSubview:_sureButton];
    
    // 设置返回按钮
    _leftItemButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _leftItemButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _leftItemButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _leftItemButton.frame = CGRectMake(0, 0, 40, 30);
    [_leftItemButton setTitle:@"取消" forState:UIControlStateNormal];
    [_leftItemButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_leftItemButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftItemButton];
}

#pragma mark 取消按钮点击事件
- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 加载数据
- (void)loadData
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            return ;
        }
        _pohtoLibraryArray = [NSMutableArray array];
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                return ;
            }
            //
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if (![type isEqualToString:ALAssetTypePhoto]) {
                return;
            }
            // 保存照片
            //            [[result defaultRepresentation] fullScreenImage]; // 大图
            //            [result thumbnail]; // 小图
            [_pohtoLibraryArray addObject:result];
            [_collectionView reloadData];
        }];
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark 确定按钮点击事件
- (void)sureButtonClick
{
    NSArray *images = [self getSelectImages];
    if (self.selectImagesBlock) {
        self.selectImagesBlock(images);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 展示按钮点击事件 
- (void)showButtonClick
{
    NSArray *images = [self getSelectImages];
    ZXImageViewController *controller = [[ZXImageViewController alloc] init];
    controller.images = images;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark 获取选择的image
- (NSArray *)getSelectImages
{
    NSMutableArray *images = [NSMutableArray array];
    [_selectLibraryArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ALAsset *asset = (ALAsset *)obj;
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        [images addObject:image];
    }];
    
    return [images mutableCopy];
}

#pragma mark - UICollectionViewDelegate
#pragma mark 定义展示的cell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _pohtoLibraryArray.count;
}

#pragma mark 定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark 每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSTPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LSTPhotoCell" forIndexPath:indexPath];
    ALAsset *asset = _pohtoLibraryArray[indexPath.row];
    //            [[result defaultRepresentation] fullScreenImage]; // 大图
    //            [result thumbnail]; // 小图
    [cell.photoImage setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    cell.isSelected = NO;
    [cell.selectImage setImage:[UIImage imageNamed:kImageNormal]];
    [_selectNumbersArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *index = (NSIndexPath *)obj;
        if (indexPath.row == index.row) {
            cell.isSelected = YES;
            [cell.selectImage setImage:[UIImage imageNamed:kImageSelect]];
        }
    }];
    return cell;
}

#pragma mark 指定边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kmargin, kmargin, kmargin, kmargin);
}

#pragma mark 定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat width = (self.view.frame.size.width - 2 * kmargin) / kRowViewNumber;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

#pragma mark UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LSTPhotoCell *cell = (LSTPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"________%d", cell.isSelected);
    cell.isSelected = !cell.isSelected;
    if (cell.isSelected && (_selectNumbersArray.count + self.hasSelectNumber) >= kSelectNumMax) {
        cell.isSelected = NO;
//        [SVProgressHUD showInfoWithStatus:@"最多发布4张图片" maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showInfoWithStatus:@"最多发布4张图片" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if (cell.isSelected) {
        [cell.selectImage setImage:[UIImage imageNamed:kImageSelect]];
        [_selectNumbersArray addObject:indexPath];
        [_selectLibraryArray addObject:_pohtoLibraryArray[indexPath.row]];
    }else{
        [cell.selectImage setImage:[UIImage imageNamed:kImageNormal]];
        [_selectNumbersArray removeObject:indexPath];
        [_selectLibraryArray removeObject:_pohtoLibraryArray[indexPath.row]];
    }
    NSString *title = [NSString stringWithFormat:@"确定(%lu)", (unsigned long)_selectLibraryArray.count];
    if (_selectLibraryArray.count == 0) {
        title = @"确定";
    }
    [_sureButton setTitle:title forState:UIControlStateNormal];
    [_sureButton setTitle:title forState:UIControlStateHighlighted];
    NSLog(@"________%d", cell.isSelected);
    NSLog(@"+++---%ld", (long)indexPath.row);
}

#pragma mark 返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
