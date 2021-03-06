//
// ZXImageView.m
//
// Copyright (c) 2015 Zhao Xin (https://github.com/xinyzhao/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXImageView.h"

@interface ZXImageView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation ZXImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        CGRect rect = self.bounds;
        self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        //
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:self.activityIndicatorView];
        //
        rect = self.scrollView.bounds;
        self.imageView = [[UIImageView alloc] initWithFrame:rect];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.imageView];
        //
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

- (void)dealloc
{
    [self.imageView sd_cancelCurrentAnimationImagesLoad];
    [self.imageView sd_cancelCurrentImageLoad];
}

#pragma mark Set Image

- (void)centerImageView {
    CGRect rect = self.imageView.frame;
    CGSize size = self.scrollView.bounds.size;
    if (rect.size.width < size.width) {
        rect.origin.x = (size.width - rect.size.width) / 2.0f;
    } else {
        rect.origin.x = 0.0f;
    }
    if (rect.size.height < size.height) {
        rect.origin.y = (size.height - rect.size.height) / 2.0f;
    } else {
        rect.origin.y = 0.0f;
    }
    self.imageView.frame = rect;
}

- (UIImage *)imageForScreenWidth:(UIImage *)image {
    CGSize size = [self imageSizeForScreenScale:image];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = width / size.width;
    size.width = width;
    size.height *= scale;
    //
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return image;
}

- (CGSize)imageSizeForScreenScale:(UIImage *)image {
    CGSize size = image.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (image.scale != scale) {
        size.width *= image.scale / scale;
        size.height *= image.scale / scale;
    }
    return size;
}

- (CGSize)imageSizeForScreenWidth:(UIImage *)image {
    CGSize size = [self imageSizeForScreenScale:image];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = width / size.width;
    size.width = width;
    size.height *= scale;
    return size;
}

- (void)setImage:(UIImage *)image {
    _image = [image copy];
    //
    if (self.image) {
        CGSize imageSize = [self imageSizeForScreenScale:image];
        CGRect imageRect = CGRectZero;
        CGSize contentSize = self.scrollView.frame.size;
        CGPoint contentOffset = CGPointZero;
        CGFloat minimumZoomScale = 1.f;
        CGFloat maximumZoomScale = 3.f;
        //
        if (imageSize.width < contentSize.width) {
            image = [self imageForScreenWidth:image];
            imageSize = [self imageSizeForScreenScale:image];
        }
        //
        if (imageSize.width > contentSize.width || imageSize.height > contentSize.height) {
            imageRect.size = contentSize;
            //
            CGFloat w = imageSize.width / contentSize.width;
            CGFloat h = imageSize.height / contentSize.height;
            if (w < h) {
                imageRect.size.width = imageSize.width / h;
            } else {
                imageRect.size.height = imageSize.height / w;
            }
            //
            maximumZoomScale = MAX(maximumZoomScale, MAX(w, h));
        } else {
            imageRect.origin.x = (contentSize.width - imageSize.width) / 2;
            imageRect.origin.y = (contentSize.height - imageSize.height) / 2;
            imageRect.size = imageSize;
        }
        //
        self.imageView.frame = imageRect;
        self.imageView.image = image;
        self.scrollView.contentSize = imageRect.size;
        self.scrollView.contentOffset = contentOffset;
        self.scrollView.minimumZoomScale = minimumZoomScale;
        self.scrollView.maximumZoomScale = maximumZoomScale;
        //
        CGSize scaleSize = [self imageSizeForScreenWidth:image];
        if (scaleSize.height > contentSize.height) {
            self.scrollView.zoomScale = scaleSize.height / contentSize.height;
        } else {
            [self centerImageView];
        }
        //
        self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        self.doubleTap.delegate = self;
        self.doubleTap.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:self.doubleTap];
        [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
        //
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [self.imageView addGestureRecognizer:self.longPress];
        //
        [self.imageView setUserInteractionEnabled:YES];
        
    } else {
        self.imageView.image = image;
    }
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = [imageURL copy];
    //
    if (self.imageURL) {
        if ([self.delegate respondsToSelector:@selector(imageView:willShowActivityIndicatorView:)]) {
            [self.delegate imageView:self willShowActivityIndicatorView:self.activityIndicatorView];
        }
        [self.activityIndicatorView startAnimating];
        [self.imageView setUserInteractionEnabled:NO];
        [self.imageView sd_setImageWithURL:self.imageURL
                          placeholderImage:self.image
                                   options:self.image ? SDWebImageRetryFailed : SDWebImageRetryFailed|SDWebImageProgressiveDownload
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     [self.activityIndicatorView stopAnimating];
                                     if (error) {
                                         NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
                                     } else if (image) {
                                         self.image = image;
                                     }
                                 }];
    }
}

- (void)setImageWithURL:(NSURL *)imageURL placeholderImage:(UIImage *)image {
    self.image = image;
    self.imageURL = imageURL;
}

#pragma mark Target Actions

- (void)onSingleTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageViewDidSingleTap:)]) {
        [self.delegate imageViewDidSingleTap:self];
    }
}

- (void)onDoubleTap:(id)sender {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        UITapGestureRecognizer *tap = sender;
        CGRect rect = self.scrollView.frame;
        CGPoint point = [tap locationInView:self.imageView];
        CGFloat scale = self.scrollView.maximumZoomScale;
        rect.size.width = self.scrollView.frame.size.width / scale;
        rect.size.height = self.scrollView.frame.size.height / scale;
        rect.origin.x = point.x - rect.size.width / 2;
        rect.origin.y = point.y - rect.size.height / 2;
        [self.scrollView zoomToRect:rect animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(imageViewDidDoubleTap:)]) {
        [self.delegate imageViewDidDoubleTap:self];
    }
}

- (void)onLongPress:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageViewDidLongPress:)]) {
        UILongPressGestureRecognizer *lp = sender;
        if (lp.state == UIGestureRecognizerStateBegan) {
            [self.delegate imageViewDidLongPress:self];
        }
    }
}

#pragma mark <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImageView];
}

@end
