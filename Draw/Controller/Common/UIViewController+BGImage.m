//
//  UIViewController+BGImage.m
//  Draw
//
//  Created by Gamy on 13-12-20.
//
//

#import "UIViewController+BGImage.h"
#import "UIImageView+WebCache.h"
#import "ShareImageManager.h"

#define BGIMAGEVIEW_TAG 20131220

@implementation UIViewController(BGImage)

- (UIImageView *)bgImageView
{
    return [self getBGView];
}

- (UIImageView *)getBGView
{
    UIImageView *bgView = (id)[self.view viewWithTag:BGIMAGEVIEW_TAG];
    if (bgView == nil) {
        bgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        bgView.tag = BGIMAGEVIEW_TAG;
        bgView.autoresizingMask = (0x1 << 6) - 1;
        [self.view insertSubview:bgView atIndex:0];
        [bgView release];
    }
    return bgView;
}

- (void)setBGImage:(UIImage *)image
{
    [[self getBGView] setImage:image];
}

- (void)setDefaultBGImage
{
    UIImage* defaultImage = [[ShareImageManager defaultManager] drawBGImage];
    [self setBGImage:defaultImage];
}

- (void)setBGImageURL:(NSURL *)imageURL
{
    [[self getBGView] setImageWithURL:imageURL];
}

- (void)setBGImageURL:(NSURL *)imageURL placeholder:(UIImage *)image
{
    [[self getBGView] setImageWithURL:imageURL placeholderImage:image];
}


@end
