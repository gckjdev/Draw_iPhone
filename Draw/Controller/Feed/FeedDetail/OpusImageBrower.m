//
//  OpusImageBrower.m
//  Draw
//
//  Created by 王 小涛 on 13-7-12.
//
//

#import "OpusImageBrower.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "ShowFeedController.h"

#define PAGE_WIDTH CGRectGetWidth([[UIScreen mainScreen] bounds])//(ISIPAD ? 768 : 320)
#define PAGE_HEIGHT (CGRectGetHeight([[UIScreen mainScreen] applicationFrame]) + STATUSBAR_DELTA)//(ISIPAD ? 1004 : 460)
#define FRAME CGRectMake(0, 0, PAGE_WIDTH, PAGE_HEIGHT) //(ISIPAD ? CGRectMake(0, 0, 768, 1004) : CGRectMake(0, 0, 320, 460))
//#define FONT (ISIPAD ? 1004 : 460)
//#define VALUE(x) (ISIPAD ? (2*(x)) : (x))

#define OPUS_IMAGEVIEW_TAG 200
#define OPUS_THUMB_IMAGEVIEW_TAG 300
#define OPUS_DESC_LABEL_TAG 300

#define THUMB_IMAGE_VIEW_FRAME   (ISIPAD ? CGRectMake(0, 0, 600, 600) : CGRectMake(0, 0, 300, 300))

#define PAGE_INDICATOR_WIDTH (ISIPAD ? 120 : 60)
#define DESC_LABEL_HEIGHT (ISIPAD ? 60 : 30)

#define DESC_LABEL_FONT (ISIPAD ? [UIFont systemFontOfSize:24] : [UIFont systemFontOfSize:12])
#define DESC_LABEL_SHADOW_OFFSET (ISIPAD ? CGSizeMake(2, 2) : CGSizeMake(1, 1))

@interface OpusImageBrower()
@property (retain, nonatomic) NSArray *feedList;
@property (retain, nonatomic) PageScrollView *pageScroller;

@end

@implementation OpusImageBrower

- (void)dealloc {
    [_feedList release];
    [_pageScroller release];
    PPRelease(_superViewController);
    [super dealloc];
}



- (id)initWithFeedList:(NSArray *)feedList{
    
    if (self = [super init]) {
        
        self.frame = FRAME;
        self.feedList = feedList;
        
        self.pageScroller = [PageScrollViewFactory createPageScrollViewWithCycle:NO];
        _pageScroller.frame = FRAME;
        [_pageScroller hidePageControl];
        _pageScroller.backgroundColor = [UIColor blackColor];
        _pageScroller.delegate = self;
        _pageScroller.datasource  = self;
        [_pageScroller reloadData];
        [self addSubview:_pageScroller];
    }
    
    return self;
}

- (UIView *)createViewWithIndex:(int)index{
    
    DrawFeed *feed = [_feedList objectAtIndex:index];

    NSURL *url = feed.largeImageURL;
    NSURL *thumbUrl = feed.thumbURL;
    NSString *desc = feed.opusDesc;
    return [self createViewWithIndex:index
                            imageUrl:url
                       thumbImageUrl:thumbUrl
                                desc:desc];
}

// 左右滑动也可以退出
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    [self.pageScroller handleTap:nil];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.scale < 1) {
        [pinch.view setTransform:CGAffineTransformMakeScale(pinch.scale, pinch.scale)];
        [_pageScroller setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    }

    if (pinch.state == UIGestureRecognizerStateRecognized) {
        if (pinch.scale < 0.6) {
            [UIView animateWithDuration:0.5 animations:^{
                
                [pinch.view updateOriginX:(pinch.view.frame.origin.x + PAGE_WIDTH)];

            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
            
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                [pinch.view setTransform:CGAffineTransformIdentity];
            } completion:^(BOOL finished) {
                [_pageScroller setBackgroundColor:[UIColor blackColor]];
            }];
        }
    }
}

- (void)setIndex:(int)index{
    PPDebug(@"index = %d", index);
    [_pageScroller scrollToPageIndex:index];
}

#define PLAY_BUTTON_TAG 2014052101

- (UIView *)createViewWithIndex:(int)index
                       imageUrl:(NSURL *)url
                  thumbImageUrl:(NSURL *)thumbUrl
                           desc:(NSString *)desc{
    
    DrawFeed *feed = [_feedList objectAtIndex:index];
    
    UIButton *view = [[[UIButton alloc] initWithFrame:FRAME] autorelease];
    view.tag = index;
    
    UIGestureRecognizer *r = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)]autorelease];
    r.delegate = self;
    [view addGestureRecognizer:r];
    
    UIImageView *opusImageView = [[UIImageView alloc] initWithFrame:view.bounds];
    opusImageView.contentMode = UIViewContentModeScaleAspectFit;
    opusImageView.tag = OPUS_IMAGEVIEW_TAG;
    [view addSubview:opusImageView];
    [opusImageView release];
    
    UIImageView *thumbImageView = nil;
    UIActivityIndicatorView *indicator = nil;
    
    if (thumbUrl != nil) {

        thumbImageView = [[UIImageView alloc] initWithFrame:THUMB_IMAGE_VIEW_FRAME];
        thumbImageView.center = CGPointMake(PAGE_WIDTH/2, PAGE_HEIGHT/2);
        thumbImageView.tag = OPUS_THUMB_IMAGEVIEW_TAG;
        thumbImageView.contentMode = UIViewContentModeScaleAspectFit;
        [view addSubview:thumbImageView];
        [thumbImageView release];
        
        [thumbImageView setImageWithURL:thumbUrl placeholderImage:nil completed:NULL];
        
        indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        indicator.center = CGPointMake(PAGE_WIDTH/2, PAGE_HEIGHT/2);
        [view addSubview:indicator];
        [indicator startAnimating];
    }
    
    if (url != nil) {
        
        [opusImageView setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
           
            if (error == nil) {
                [opusImageView updateWidth:MIN(image.size.width, PAGE_WIDTH)];
                [opusImageView updateHeight:MIN(image.size.height, PAGE_HEIGHT)];
                opusImageView.center = CGRectGetCenter(view.bounds);//CGPointMake(PAGE_WIDTH/2, PAGE_HEIGHT/2);
                [indicator stopAnimating];

                if (cacheType == SDImageCacheTypeNone) {
                    opusImageView.alpha = 0;

                    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        thumbImageView.frame = opusImageView.frame;
                    } completion:^(BOOL finished) {
                        [thumbImageView removeFromSuperview];
                        opusImageView.alpha = 1;
                    }];
                }else{
                    [thumbImageView removeFromSuperview];
                }
            }else{
                [indicator stopAnimating];
            }
        }];
        
    }
    
    int yGap = (ISIPAD ? 40 : 20);
    int xSp = (ISIPAD ? 20 : 10);
    UILabel *descLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, PAGE_HEIGHT - DESC_LABEL_HEIGHT - yGap, PAGE_WIDTH - 20*2 - PAGE_INDICATOR_WIDTH - xSp, DESC_LABEL_HEIGHT)] autorelease];
    descLabel.tag = OPUS_DESC_LABEL_TAG;
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.textColor = [UIColor whiteColor];
    descLabel.shadowColor = [UIColor blackColor];
    
    descLabel.shadowOffset = DESC_LABEL_SHADOW_OFFSET;
    descLabel.font = DESC_LABEL_FONT;
    descLabel.numberOfLines = 2;
    if (feed.pbFeed.spendTime || feed.pbFeed.strokes){
        // 有时间和笔画数目，显示附加信息
        NSString* str = @"";
        if ([feed.pbFeed.deviceName length] > 0){
            str = [str stringByAppendingFormat:NSLS(@"kDrawDevice"), [DeviceDetection deviceNameByModel:feed.pbFeed.deviceName]];
            str = [str stringByAppendingString:@"\t"];
        }

        if (feed.pbFeed.strokes > 0){
            NSString* strokesString = [DrawUtils strokesString:feed.pbFeed.strokes];
            str = [str stringByAppendingFormat:NSLS(@"kDrawStrokes"), strokesString];
            str = [str stringByAppendingString:@"\t"];
        }
        
        if (feed.pbFeed.spendTime > 0){
            NSString* spendTimeString = [DrawUtils spendTimeString:feed.pbFeed.spendTime];
            str = [str stringByAppendingString:spendTimeString];
        }
        
        if ([str length] > 0){
            descLabel.text = str;
            
            // center display label
            descLabel.textAlignment = NSTextAlignmentCenter;
            CGPoint center = CGPointMake(self.center.x, descLabel.center.y);
            [descLabel setCenter:center];
        }
        else{
            descLabel.text = desc;
        }
    }
    else{
        descLabel.text = desc;
    }
    [view addSubview:descLabel];

    // create PLAY button
    if ([[UserManager defaultManager] isEnableReplay]){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect buttonFrame = self.frame;
        buttonFrame.size = ISIPAD ? CGSizeMake(180, 180) : CGSizeMake(80, 80);
        [button setBackgroundImage:[UIImage imageNamed:@"play3.png"] forState:UIControlStateNormal];
        [button setFrame:buttonFrame];
        [button setCenter:self.center];
        [button setAlpha:0.0];
        [button setTag:PLAY_BUTTON_TAG];
        [button addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        [UIView animateWithDuration:0.8 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
            button.alpha = 0.8;
        } completion:^(BOOL finished) {
        }];
    }

    
    CGRect frame = CGRectMake(PAGE_WIDTH - PAGE_INDICATOR_WIDTH - 20, descLabel.frame.origin.y, PAGE_INDICATOR_WIDTH, DESC_LABEL_HEIGHT);
    UILabel *pageIndicator = [[[UILabel alloc] initWithFrame:frame] autorelease];
    pageIndicator.backgroundColor = [UIColor clearColor];
    pageIndicator.textColor = [UIColor whiteColor];
    pageIndicator.shadowColor = [UIColor blackColor];
    pageIndicator.shadowOffset = DESC_LABEL_SHADOW_OFFSET;
    pageIndicator.font = DESC_LABEL_FONT;
    pageIndicator.textAlignment = UITextAlignmentRight;
    pageIndicator.text = [NSString stringWithFormat:@"[%d/%d]", index+1, [_feedList count]];
    [view addSubview:pageIndicator];
    
    pageIndicator.hidden = YES;
    
    return view;
}

- (void)replay
{
    if ([self.feedList count] == 0)
        return;
    
//    if (_isReplaying)
//        return;
    
    _isReplaying = YES;
    DrawFeed* drawFeed = [self.feedList objectAtIndex:0];
    [ShowFeedController replayDraw:drawFeed viewController:self.superViewController];
}

//- (void)clickOpusImageButton:(UIButton *)button{
//    
//    if ([_delegate respondsToSelector:@selector(brower:didSelecteFeed:)]) {
//        int index = button.tag;
//        DrawFeed *feed = [_feedList objectAtIndex:index];
//        [_delegate brower:self didSelecteFeed:feed];
//    }
//}

#define OPUS_VIEW_ANMIATION_SECONDS 0.8f
#define MOVE_OFFSET [[UIScreen mainScreen] bounds].size.width

- (void)showInViewController:(PPViewController *)viewController
{
    self.superViewController = viewController;
    [self showInView:viewController.view];
}

- (void)showInView:(UIView *)view{
    
    [view addSubview:self];

    
//    [self updateOriginY:PAGE_HEIGHT];
    
    
    self.alpha = 0;
    __block typeof (self) bself = self;
    
    [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        bself.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
//    self.frame = view.bounds;
//    CGFloat x = CGRectGetMidX(self.frame);
//    
//    [self updateCenterX:x-MOVE_OFFSET];
//    
//    [UIView animateWithDuration:OPUS_VIEW_ANMIATION_SECONDS animations:^{
//        [self updateCenterX:x];
//    } completion:^(BOOL finished) {
//        [self updateCenterX:x];
//    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag == PLAY_BUTTON_TAG){
        if ([DeviceDetection isOS6] == NO){
            [self replay];
        }
    }
    return YES;
}

//// called when scroll view grinds to a halt
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//    int index = scrollView.contentOffset.x / PAGE_WIDTH;
//    
//    [self loadLargeImageWithIndex:index];
//}


//- (void)loadLargeImageWithIndex:(int)index{
//    
//    DrawFeed *feed = [_feedList objectAtIndex:index];
//    NSURL *url = feed.largeImageURL;
//    
//    UIView *view = [_pageScroller viewWithTag:index];
//    UIImageView *opusImageView = (UIImageView *)[view viewWithTag:OPUS_IMAGEVIEW_TAG];
//    UIImageView *thumbImageView = (UIImageView *)[view viewWithTag:OPUS_THUMB_IMAGEVIEW_TAG];
//    
//    UIActivityIndicatorView * indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
//    indicator.center = CGPointMake(PAGE_WIDTH/2, PAGE_HEIGHT/2);
//    [view addSubview:indicator];
//    [indicator startAnimating];
//    
//    if (url != nil) {
//        
//        [opusImageView setImageWithURL:url placeholderImage:nil success:^(UIImage *image, BOOL cached) {
//            [indicator stopAnimating];
//            [thumbImageView removeFromSuperview];
//        } failure:^(NSError *error) {
//            [indicator stopAnimating];
//        }];
//    }
//}


#define DETAIL_CONTROLLER_OPUS_FRAME (ISIPAD ? CGRectMake(22, 13 + 115 + 41, 680, 460) : CGRectMake(1, 3 + 45 + 100, 300, 230))

- (void)pageScrollView:(PageScrollView *)csView didClickOnPage:(UIView *)view atIndex:(NSInteger)index{
    
    if ([_delegate respondsToSelector:@selector(brower:didSelecteFeed:)]) {
        DrawFeed *feed = [_feedList objectAtIndex:index];
        
        [UIView animateWithDuration:1 animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            [_delegate brower:self didSelecteFeed:feed];
            [self removeFromSuperview];
            self.superViewController = nil;
        }];
    }
}

- (NSInteger)numberOfPagesInPageScrollView:(PageScrollView *)psView{
    
    return [_feedList count];
}

- (UIView *)pageScrollView:(PageScrollView *)psView pageAtIndex:(NSInteger)index{
    
    if (index >=0 && index < [_feedList count]) {
        UIView *view = [self createViewWithIndex:index];
        return view;
    }
    
    return nil;
}


@end
