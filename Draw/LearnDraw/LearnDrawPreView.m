//
//  LearnDrawPreView.m
//  Draw
//
//  Created by gamy on 13-4-15.
//
//

#import "LearnDrawPreView.h"
#import "UIImageView+WebCache.h"
#import "DrawFeed.h"
#import "CustomInfoView.h"

@interface LearnDrawPreView ()
{
    
}

@property(nonatomic, assign)DrawFeed *feed;
@end

@implementation LearnDrawPreView

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    self.feed = nil;
    PPRelease(_placeHolderImage);
    [super dealloc];
}

#define HEIGHT ((ISIPAD ? 150 : 80) + 20)

+ (LearnDrawPreView *)learnDrawPreViewWithDrawFeed:(DrawFeed *)feed
                                  placeHolderImage:(UIImage *)image
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGSize size = frame.size; size.height -= HEIGHT;
    frame.size = size;
    
    
    LearnDrawPreView *view = [[LearnDrawPreView alloc] initWithFrame:frame];
    view.feed = feed;
    view.placeHolderImage = image;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImageWithURL:feed.largeImageURL placeholderImage:view.placeHolderImage];
    [view addSubview:imageView];
    [imageView release];
    
    return [view autorelease];
}

- (void)preView
{
    PPDebug(@"preview");
}

- (void)buyToView
{
    PPDebug(@"buyToView");    
}

- (void)showInView:(UIView *)view
{
    CustomInfoView *cInfoView = [CustomInfoView createWithTitle:NSLS(@"kLearnDrawPreview") infoView:self hasCloseButton:YES buttonTitles:[NSArray arrayWithObjects:NSLS(@"kPreview"),NSLS(@"kBuyToView"), nil]];

    __block LearnDrawPreView *cp = self;
    
    [cInfoView setActionBlock:^(UIButton *button, UIView *infoView){
        NSString *title = [button titleForState:UIControlStateNormal];
        if ([title isEqualToString:NSLS(@"kPreview")]) {
            [cp preView];
        }else if([title isEqualToString:NSLS(@"kBuyToView")]){
            [cp buyToView];
        }
        [cInfoView setActionBlock:NULL];
    }];
    [cInfoView showInView:view];
}

- (void)dismiss
{
    [self removeFromSuperview];
}


@end
