//
//  CopyView.m
//  Draw
//
//  Created by qqn_pipi on 14-6-24.
//
//

#import "CopyView.h"
#import "SPUserResizableView.h"
#import "MKBlockActionSheet.h"
#import "UserFeedController.h"
#import "DrawPlayer.h"
#import "ShowFeedController.h"

#define COPY_VIEW_DEFAULT_WIDTH     (ISIPAD ? 250 : 100)
#define COPY_VIEW_DEFAULT_HEIGHT    (ISIPAD ? 250 : 100)

@interface CopyView()

@property (nonatomic, retain) PPViewController *superViewController;
@property (nonatomic, retain) DrawFeed *drawFeed;

@end

@implementation CopyView

+ (CopyView*)createCopyView:(PPViewController*)superViewController superView:(UIView*)superView atPoint:(CGPoint)point
{
    CGRect frame = CGRectMake(point.x, point.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
    CopyView *copyView = [[CopyView alloc] initWithFrame:frame];
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:frame];
//    [contentView setContentMode:UIViewContentModeScaleAspectFill];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.alpha = 0.9;
    copyView.contentView = contentView;

    [superView addSubview:copyView];
    copyView.superViewController = superViewController;
    copyView.delegate = copyView;
    
    [contentView release];
    [copyView release];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:copyView action:@selector(hideBorder)];
    [gestureRecognizer setDelegate:copyView];
    [superView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    [copyView showEditingHandles];
    [copyView loadLatestOpus];
    
    return copyView;
}

- (void)dealloc
{
    PPRelease(_drawFeed);
    PPRelease(_superViewController);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#define KEY_COPY_VIEW_LATEST_OPUS_ID    @"KEY_COPY_VIEW_LATEST_OPUS_ID"

- (void)setLatestOpusId:(NSString*)opusId
{
    UD_SET(KEY_COPY_VIEW_LATEST_OPUS_ID, opusId);
}

- (void)loadLatestOpus
{
    NSString* opusId = UD_GET(KEY_COPY_VIEW_LATEST_OPUS_ID);
    if (opusId){
        [self loadAndUpdate:opusId updateImage:YES];
    }
}

- (void)loadImageRemote:(DrawFeed *)feed
{
    if ([feed.drawImageUrl length] != 0){
        
        __block UIImage *placeholderImage = nil;
        
        [[SDWebImageManager sharedManager] downloadWithURL:feed.thumbURL options:SDWebImageRetryFailed progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            
            if (finished && error == nil) {
                placeholderImage = image;
            }
        }];
        
        if (feed.largeImage == nil) {
            placeholderImage = [[ShareImageManager defaultManager] unloadBg];
        }else{
            placeholderImage = feed.largeImage;
        }
        
        UIImageView* imageView = (UIImageView*)(self.contentView);
        [imageView setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            feed.largeImage = image;
            if (image) {
                [imageView setImage:image];
            }
        }];
        
        return;
    }
}

- (void)loadAndUpdate:(NSString*)opusId updateImage:(BOOL)updateImage
{
    if ([opusId length] > 0){
        [self.superViewController showActivityWithText:NSLS(@"kLoading")];
        [[FeedService defaultService] getFeedByFeedId:opusId completed:^(int resultCode, DrawFeed *feed, BOOL fromCache) {
            [self.superViewController hideActivity];
            if (resultCode == 0 && feed) {
                self.drawFeed = feed;
                if (updateImage){
                    [self loadImageRemote:feed];
                }
            }else{
                POSTMSG(NSLS(@"kLoadFail"));
            }
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - SPUserResizableViewDelegate

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
    PPDebug(@"userResizableViewDidBeginEditing");
}

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    PPDebug(@"userResizableViewDidEndEditing");
}

- (void)updateCopyImageView:(UIImage*)image
{
    if (image == nil){
        return;
    }

    if ([self.contentView isKindOfClass:[UIImageView class]]){
        [((UIImageView*)self.contentView) setImage:image];
    }
}

#define COPY_VIEW_SET_IMAGE NSLS(@"kCopyViewSetImage")
#define COPY_VIEW_PLAY      NSLS(@"kPlayCopyView")
#define COPY_VIEW_HIDE      NSLS(@"kHideCopyView")
#define COPY_VIEW_HELP      NSLS(@"kCopyViewHelp")

- (void)userResizableViewDidTap:(SPUserResizableView*)userResizableView
{
    PPDebug(@"userResizableViewDidTap");
    
    
    
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kCopyViewActionTitle")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLS(@"Cancel")
                                                         destructiveButtonTitle:COPY_VIEW_SET_IMAGE
                                                              otherButtonTitles:COPY_VIEW_PLAY, COPY_VIEW_HIDE, COPY_VIEW_HELP, nil];
    
    [actionSheet setActionBlock:^(NSInteger buttonIndex){
        NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([title isEqualToString:COPY_VIEW_SET_IMAGE]){
            PPDebug(@"click COPY_VIEW_SET_IMAGE");
            [UserFeedController selectOpus:self.superViewController
                                  callback:^(int resultCode, NSString *opusId, UIImage *opusImage, int opusCategory) {
                if (resultCode == 0 && [opusId length] > 0){
                    
                    [self setLatestOpusId:opusId];
                    [self updateCopyImageView:opusImage];
                    [self loadAndUpdate:opusId updateImage:NO];
                }
                else{
                }
            }];
        }
        else if ([title isEqualToString:COPY_VIEW_PLAY]){
            PPDebug(@"click COPY_VIEW_PLAY");
            [ShowFeedController replayDraw:self.drawFeed viewController:self.superViewController];
        }
        else if ([title isEqualToString:COPY_VIEW_HIDE]){
            PPDebug(@"click COPY_VIEW_HIDE");
            [self setHidden:YES];
        }
        else if ([title isEqualToString:COPY_VIEW_HELP]){
            PPDebug(@"click COPY_VIEW_HELP");
        }
    }];
    
    [actionSheet showInView:self.superViewController.view];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self hitTest:[touch locationInView:self] withEvent:nil]) {
        return NO;
    }
    return YES;
}

- (void)hideBorder {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [self hideEditingHandles];
}

@end