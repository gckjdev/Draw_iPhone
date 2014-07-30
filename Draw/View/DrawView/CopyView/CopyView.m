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
#import "UserTutorialService.h"
#import "Draw.h"
#import "TipsPageViewController.h"

#define COPY_VIEW_DEFAULT_WIDTH     (ISIPAD ? 180 : 80)
#define COPY_VIEW_DEFAULT_HEIGHT    (ISIPAD ? 180 : 80)

@interface CopyView()

@property (nonatomic, retain) PPViewController *superViewController;
@property (nonatomic, retain) DrawFeed *drawFeed;
@property (nonatomic, retain) UIImage *displayImage;
@property (nonatomic, assign) BOOL hasMenu;

@property (nonatomic, retain) NSString *opusBgImagePath;
@property (nonatomic, retain) NSString *opusDataPath;

@property (nonatomic, retain) UIImage *opusBgImage;
@property (nonatomic, retain) NSData *opusData;
@property (nonatomic, assign) int opusStartIndex;
@property (nonatomic, assign) int opusEndIndex;
@property (nonatomic, retain) Draw *draw;

@property (nonatomic, retain) PBUserStage *userStage;
@property (nonatomic, retain) PBStage *stage;


@end

@implementation CopyView

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                     opusId:(NSString*)opusId
                  userStage:(PBUserStage*)userStage
                      stage:(PBStage*)stage
{
    CGRect frame = CGRectMake(point.x, point.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
    CopyView *copyView = [[CopyView alloc] initWithFrame:frame];
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:frame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.alpha = 0.8;
    copyView.contentView = contentView;

    [superView addSubview:copyView];
    copyView.superViewController = superViewController;
    copyView.delegate = copyView;
    
    [contentView release];
    [copyView release];
    
    [copyView showEditingHandles];
    [copyView loadOpus:opusId userStage:userStage stage:stage];
    
    copyView.hasMenu = YES;
    
    return copyView;
}

- (UIImage*)image
{
    return _displayImage;
}

- (UIImage*)imageForCompare
{
    UIImage* retImage = nil;
    if (self.userStage){
        // TODO create image from opus data
        
        // support with bgImage or no bg image
        
    }
    else{
        return _displayImage;
    }
    
    if (retImage == nil){
        return _displayImage;
    }
    else{
        return retImage;
    }
}

- (void)dealloc
{
    PPRelease(_opusBgImagePath);
    PPRelease(_opusDataPath);
    PPRelease(_opusBgImage);
    PPRelease(_opusData);
    
    PPRelease(_userStage);
    PPRelease(_stage);
    
    PPRelease(_draw);
    PPRelease(_drawFeed);
    PPRelease(_superViewController);
    PPRelease(_displayImage);
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

- (void)loadOpus:(NSString*)opusId userStage:(PBUserStage*)userStage stage:(PBStage*)stage
{
    if (userStage){
        // for learn draw
        [self loadData:userStage stage:stage];
    }
    else{
        if (opusId){
            [self loadAndUpdate:opusId updateImage:YES];
        }
        else{
            [self loadLatestOpus];
        }
    }
}

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
            self.displayImage = feed.largeImage;
        }
        
        UIImageView* imageView = (UIImageView*)(self.contentView);
        [imageView setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            feed.largeImage = image;
            if (image) {
                [imageView setImage:image];
                self.displayImage = image;
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

- (void)setImage:(UIImage*)image
{
    self.displayImage = image;
    UIImageView* imageView = (UIImageView*)(self.contentView);
    [imageView setImage:image];
}

- (void)loadData:(PBUserStage*)userStage stage:(PBStage*)stage
{
    NSString* imagePath = [[UserTutorialService defaultService] getChapterImagePath:userStage.tutorialId stage:stage chapterIndex:userStage.currentChapterIndex];
    
    NSString* bgImagePath = [[UserTutorialService defaultService] getBgImagePath:userStage.tutorialId stage:stage];
    NSString* opusDataPath = [[UserTutorialService defaultService] getOpusDataPath:userStage.tutorialId stage:stage];

    // set display image
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    [self setImage:image];
    [image release];
    
    self.opusDataPath = opusDataPath;
    self.opusBgImagePath = bgImagePath;
    
    self.userStage = userStage;
    self.stage = stage;
    
    if (userStage.currentChapterIndex < [self.stage.chapterList count]){
        PBChapter* chapter = [self.stage.chapterList objectAtIndex:userStage.currentChapterIndex];
        self.opusStartIndex = chapter.startIndex;
        self.opusEndIndex = chapter.endIndex;
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
    
#ifndef DEBUG
    if (_hasMenu == NO){
        // tap to play opus directly
        [ShowFeedController replayDraw:self.drawFeed viewController:self.superViewController];
        return;
    }
#endif
    
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
                    self.displayImage = opusImage;
                    [self loadAndUpdate:opusId updateImage:YES]; // TODO change to NO?
                }
                else{
                }
            }];
        }
        else if ([title isEqualToString:COPY_VIEW_PLAY]){
            PPDebug(@"click COPY_VIEW_PLAY");
            if (self.userStage){
                if (_draw == nil){
                    // load opus data
                    self.opusData = [[[NSData alloc] initWithContentsOfFile:self.opusDataPath] autorelease];
                }
                
                [DrawPlayer playDrawData:&_opusData
                                    draw:&_draw
                          viewController:self.superViewController
                              startIndex:_opusStartIndex
                                endIndex:_opusEndIndex];
            }
            else{
                [ShowFeedController replayDraw:self.drawFeed viewController:self.superViewController];
            }
        }
        else if ([title isEqualToString:COPY_VIEW_HIDE]){
            PPDebug(@"click COPY_VIEW_HIDE");
            [self setHidden:YES];
        }
        else if ([title isEqualToString:COPY_VIEW_HELP]){
            // view tips
            if (self.userStage){
                NSArray* tipsPaths = [[UserTutorialService defaultService] getChapterTipsImagePath:_userStage.tutorialId
                                                                                             stage:self.stage
                                                                                      chapterIndex:_userStage.currentChapterIndex];
                NSString* title = @"提示";
                [TipsPageViewController show:self.superViewController title:title imagePathArray:tipsPaths];
            }
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

- (void)enableMenu
{
    _hasMenu = YES;
}

- (void)disableMenu
{
    _hasMenu = NO;
}


@end
