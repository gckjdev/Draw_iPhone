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
#import "DrawConstants.h"
#import "ChangeAvatar.h"
#import "OfflineDrawViewController.h"
#import "DrawToolUpPanel.h"
#import "TGRImageViewController.h"

#define COPY_VIEW_DEFAULT_WIDTH     (ISIPAD ? 180 : 80)
#define COPY_VIEW_DEFAULT_HEIGHT    (ISIPAD ? 180 : 80)

@interface CopyView()

@property (nonatomic, assign) PPViewController *superViewController;
@property (nonatomic, retain) DrawFeed *drawFeed;
@property (nonatomic, retain) UIImage *displayImage;
@property (nonatomic, assign) BOOL hasMenu;

@property (nonatomic, retain) NSString *opusImagePath;
@property (nonatomic, retain) NSString *opusBgImagePath;
@property (nonatomic, retain) NSString *opusDataPath;

@property (nonatomic, retain) UIImage *opusBgImage;
@property (nonatomic, retain) NSData *opusData;
@property (nonatomic, assign) int opusStartIndex;
@property (nonatomic, assign) int opusEndIndex;
@property (nonatomic, assign) int targetType;
@property (nonatomic, assign) UIView* referView;
@property (nonatomic, assign) CGPoint origPoint;
@property (nonatomic, retain) Draw *draw;

@property (nonatomic, retain) PBUserStage *userStage;
@property (nonatomic, retain) PBStage *stage;
@property (nonatomic, retain) ChangeAvatar *imagePicker;

@end

@implementation CopyView

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                  referView:(UIView*)referView
                     opusId:(NSString*)opusId
                  userStage:(PBUserStage*)userStage
                      stage:(PBStage*)stage
                       type:(TargetType)type
{
    CGRect frame = CGRectMake(point.x, point.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
    CopyView *copyView = [[CopyView alloc] initWithFrame:frame];
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:frame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.alpha = 1.0;
    copyView.contentView = contentView;

    [superView addSubview:copyView];
    copyView.superViewController = superViewController;
    copyView.delegate = copyView;
    copyView.targetType = type;
    
    [contentView release];
    [copyView release];
    
    [copyView showEditingHandles];
    [copyView loadOpus:opusId userStage:userStage stage:stage];
    
    copyView.hasMenu = YES;

    copyView.origPoint = point;
    copyView.referView = referView;
    
    return copyView;
}

+ (CopyView*)createCopyView:(PPViewController*)superViewController
                  superView:(UIView*)superView
                    atPoint:(CGPoint)point
                  referView:(UIView*)referView
                      image:(UIImage*)image
                       type:(TargetType)type
{
    CGRect frame = CGRectMake(point.x, point.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
    CopyView *copyView = [[CopyView alloc] initWithFrame:frame];
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:frame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    contentView.alpha = 1.0;
    copyView.contentView = contentView;
    
    [superView addSubview:copyView];
    copyView.superViewController = superViewController;
    copyView.delegate = copyView;
    copyView.targetType = type;
    
    [contentView release];
    [copyView release];
    
    [copyView showEditingHandles];
    
    copyView.hasMenu = YES;
    [copyView setImage:image];
    
    copyView.origPoint = point;
    copyView.referView = referView;
    
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
    PPRelease(_imagePicker);
    PPRelease(_opusImagePath);
    PPRelease(_opusBgImagePath);
    PPRelease(_opusDataPath);
    PPRelease(_opusBgImage);
    PPRelease(_opusData);
    
    PPRelease(_userStage);
    PPRelease(_stage);
    
    PPRelease(_draw);
    PPRelease(_drawFeed);
    PPRelease(_displayImage);
    
    self.superViewController = nil;
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
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:image];
}

- (void)loadData:(PBUserStage*)userStage stage:(PBStage*)stage
{
    NSString* imagePath = [[UserTutorialService defaultService] getChapterImagePath:userStage.tutorialId stage:stage chapterIndex:userStage.currentChapterIndex];
    
    NSString* bgImagePath = [[UserTutorialService defaultService] getBgImagePath:userStage.tutorialId stage:stage];
    NSString* opusDataPath = [[UserTutorialService defaultService] getOpusDataPath:userStage.tutorialId stage:stage];
    
    self.opusDataPath = opusDataPath;
    self.opusBgImagePath = bgImagePath;
    self.opusImagePath = imagePath;
    
    self.userStage = userStage;
    self.stage = stage;
    
    if (userStage.currentChapterIndex < [self.stage.chapter count]){
        PBChapter* chapter = [self.stage.chapter objectAtIndex:userStage.currentChapterIndex];
        self.opusStartIndex = chapter.startIndex;
        self.opusEndIndex = chapter.endIndex;
    }
    
    // set display image
    UIImage* image = [self createImage];
    [self setImage:image];
    
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
    self.alpha = 0.7f;
}

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    PPDebug(@"userResizableViewDidEndEditing");
    self.alpha = 1.0f;
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

#define COPY_VIEW_SET_IMAGE         NSLS(@"kCopyViewSetImage")
#define COPY_VIEW_PLAY              NSLS(@"kPlayCopyView")
#define COPY_VIEW_HIDE              NSLS(@"kHideCopyView")
#define COPY_VIEW_HELP              NSLS(@"kCopyViewHelp")
#define COPY_VIEW_FULL_SCREEN       NSLS(@"kCopyViewFullScreen")
#define COPY_VIEW_DEFAULT_SCREEN    NSLS(@"kCopyViewDefaultScreen")

#define COPY_VIEW_SELECT_IMAGE      NSLS(@"设置图片")
#define COPY_VIEW_VIEW_SINGLE       NSLS(@"查看大图")
#define COPY_VIEW_RESET             NSLS(@"恢复小图")
#define COPY_VIEW_STRECTCH_SUPER    NSLS(@"铺满画板")

- (void)userResizableViewDidTap:(SPUserResizableView*)userResizableView
{
    PPDebug(@"userResizableViewDidTap");
    
//#ifndef DEBUG
//    if (_hasMenu == NO){
//        // tap to play opus directly
//        [self play];
//        [ShowFeedController replayDraw:self.drawFeed viewController:self.superViewController];
//        return;
//    }
//#endif
    
    MKBlockActionSheet* actionSheet = nil;
    if (self.targetType == TypeConquerDraw || self.targetType == TypePracticeDraw){
        actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kCopyViewActionTitle")
                                                                           delegate:nil
                                                                  cancelButtonTitle:NSLS(@"Cancel")
                                                             destructiveButtonTitle:nil //COPY_VIEW_SET_IMAGE COPY_VIEW_HIDE,
                                                                  otherButtonTitles:COPY_VIEW_PLAY, COPY_VIEW_FULL_SCREEN, COPY_VIEW_DEFAULT_SCREEN, nil];
    }
    else{
        actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kCopyViewActionTitle")
                                         delegate:nil
                                cancelButtonTitle:NSLS(@"Cancel")
                           destructiveButtonTitle:nil //COPY_VIEW_SET_IMAGE COPY_VIEW_HIDE,
                                otherButtonTitles:COPY_VIEW_SELECT_IMAGE, COPY_VIEW_STRECTCH_SUPER, COPY_VIEW_VIEW_SINGLE, COPY_VIEW_RESET, COPY_VIEW_HIDE, nil];
    }
    
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
            [self play];
        }
        else if ([title isEqualToString:COPY_VIEW_HIDE]){
            PPDebug(@"click COPY_VIEW_HIDE");
            [self setHidden:YES];
        }
        else if ([title isEqualToString:COPY_VIEW_FULL_SCREEN] || [title isEqualToString:COPY_VIEW_STRECTCH_SUPER]){
            PPDebug(@"click COPY_VIEW_FULL_SCREEN");
            self.frame = self.superview.bounds;

//            self.frame = CGRectMake(_origPoint.x, _origPoint.y, _referView.bounds.size.width, _referView.bounds.size.height);
            //            [self updateWidth:self.superview.bounds.size.width];
//            [self updateHeight:self.superview.bounds.size.height];
            self.alpha = 1.0f;
        }
        else if ([title isEqualToString:COPY_VIEW_DEFAULT_SCREEN] || [title isEqualToString:COPY_VIEW_RESET]){
            PPDebug(@"click COPY_VIEW_DEFAULT_SCREEN");
            self.frame = CGRectMake(_origPoint.x, _origPoint.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
            self.alpha = 1.0f;
        }
        else if ([title isEqualToString:COPY_VIEW_SELECT_IMAGE]){
            [self selectImageFromAlbum];
        }
        else if ([title isEqualToString:COPY_VIEW_VIEW_SINGLE]){
            [self showImage];
        }
        else if ([title isEqualToString:COPY_VIEW_HELP]){
            // view tips
            if (self.userStage){
//                NSArray* tipsPaths = [[UserTutorialService defaultService] getChapterTipsImagePath:_userStage.tutorialId
//                                                                                             stage:self.stage
//                                                                                      chapterIndex:_userStage.currentChapterIndex];
//                NSString* title = COPY_VIEW_HELP;
//
//                
//                if ([tipsPaths count] > 0){
//                    [TipsPageViewController show:self.superViewController
//                                           title:title
//                                  imagePathArray:tipsPaths
//                                    defaultIndex:0
//                                     returnIndex:NULL];
//                }
//                else{
//                    POSTMSG(NSLS(@"kHaveNotTips"));
//                }
            }
        }
    }];
    
    [actionSheet showInView:self.superViewController.view];
}

#define TEMP_REPLAY_IMAGE_NAME @"temp_replay_chapter_bg_image.png"

- (BOOL)play
{
    if (self.userStage){
        if (_draw == nil){
            // load opus data
            self.opusData = [[[NSData alloc] initWithContentsOfFile:self.opusDataPath] autorelease];
        }
        
        if (_opusData == nil && _draw == nil){
            POSTMSG(NSLS(@"kNoOpusForReplay"));
            return NO;
        }
        
        UIImage* bgImage = nil; //[[UIImage alloc] initWithContentsOfFile:_opusBgImagePath];
        
        if (_targetType == TypePracticeDraw){
            [DrawPlayer playDrawData:&_opusData
                                draw:&_draw
                      viewController:self.superViewController
                             bgImage:bgImage
                         bgImageName:TEMP_REPLAY_IMAGE_NAME
                          startIndex:_opusStartIndex
                            endIndex:_opusEndIndex
                           drawImage:self.displayImage];
        }
        else{
            [DrawPlayer playDrawData:&_opusData
                                draw:&_draw
                      viewController:self.superViewController
                             bgImage:bgImage
                         bgImageName:nil
                          startIndex:0
                            endIndex:0
                           drawImage:self.displayImage];
        }
        
        [bgImage release];
    }
    else{
        [ShowFeedController replayDraw:self.drawFeed viewController:self.superViewController];
    }
    
    return YES;
    
}

- (UIImage*)createImage
{
    UIImage* image = nil;
    
    if (self.userStage){
        if (_draw == nil){
            // load opus data
            self.opusData = [[[NSData alloc] initWithContentsOfFile:self.opusDataPath] autorelease];
        }
        
//        UIImage* bgImage = nil; //[[UIImage alloc] initWithContentsOfFile:_opusBgImagePath];
        
        int totalChapterCount = [self.stage.chapter count];
        if (_targetType == TypeConquerDraw ||
            totalChapterCount <= 1 ||
            (self.userStage.currentChapterIndex == (totalChapterCount-1))){
            // use last image
            UIImage* image = [[[UIImage alloc] initWithContentsOfFile:self.opusImagePath] autorelease];
            return image;
        }

        if (_targetType == TypePracticeDraw){
            image = [DrawPlayer createImageByDrawData:&_opusData
                                         draw:&_draw
                               viewController:self.superViewController
                                      bgImage:nil
                                  bgImageName:TEMP_REPLAY_IMAGE_NAME
                                   startIndex:0
                                     endIndex:_opusEndIndex];
        }
    }
    
    if (image == nil){
        image = [[[UIImage alloc] initWithContentsOfFile:self.opusImagePath] autorelease];
    }
    
    return image;
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

- (void)selectImageFromAlbum
{
    ChangeAvatar* ca = [[ChangeAvatar alloc] init];
    self.imagePicker = ca;
    [self.imagePicker setAutoRoundRect:NO];
    [self.imagePicker setImageSize:CGSizeMake(0, 0)];
    [self.imagePicker setIsCompressImage:NO];
    [self.imagePicker showSelectionView:self.superViewController
                               delegate:nil
                     selectedImageBlock:^(UIImage *image) {
                         OfflineDrawViewController *oc = (OfflineDrawViewController *)[self superViewController];
                         [oc saveCopyPaintImage:image];
//                         if ([cp.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
//                             [(DrawToolUpPanel*)cp.toolPanel updateCopyPaint:image];
//                         }
                     }
                     didSetDefaultBlock:^{
                         self.imagePicker = nil;
                     }
                                  title:nil
                        hasRemoveOption:NO
                           canTakePhoto:NO
                      userOriginalImage:YES];
    
    [ca release];
    
    
}

- (void)showImage
{
    dispatch_after(0, dispatch_get_main_queue(), ^{
        TGRImageViewController *vc = [[TGRImageViewController alloc] initWithImage:_displayImage];
        [self.superViewController presentViewController:vc animated:YES completion:nil];
        [vc release];
    });
}

@end
