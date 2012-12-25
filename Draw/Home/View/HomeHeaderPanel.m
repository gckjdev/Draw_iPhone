//
//  HomeHeaderView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeHeaderPanel.h"
#import "UIImageView+WebCache.h"
#import "UserManager.h"
#import "LevelService.h"
#import "AccountManager.h"
#import "AccountService.h"
#import <QuartzCore/QuartzCore.h>
#import "FeedService.h"
#import "Feed.h"
#import "DrawImageManager.h"
#import "ConfigManager.h"

@interface HomeHeaderPanel ()
{
    NSMutableArray *_feedList;
    NSTimer *_scrollTimer;
}
@property (retain, nonatomic) IBOutlet UIImageView *displayBG;
@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *level;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;
@property (retain, nonatomic) IBOutlet UILabel *coin;
@property (retain, nonatomic) IBOutlet UIScrollView *displayScrollView;
@property (retain, nonatomic) IBOutlet UIButton *freeCoin;

@property (retain, nonatomic) NSMutableArray *feedList;

- (IBAction)clickFreeCoinButton:(id)sender;
- (IBAction)clickChargeButton:(id)sender;
- (IBAction)clickAvatarButton:(id)sender;

@end

@implementation HomeHeaderPanel

+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    NSString* identifier = [HomeHeaderPanel getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    HomeCommonView<HomeCommonViewProtocol> *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
}

+ (NSString *)getViewIdentifier
{
    return [GameApp homeHeaderViewId];
}

#pragma mark - Display Top Draw...

#define IMAGE_NUMBER_PER_PAGE 3
#define SPACE_IMAGE (ISIPAD ? 4 * 2 : 4)
#define DISPLAY_SIZE (self.displayScrollView.frame.size)
#define SCROLL_INTERVAL 10

#define TOP_DRAW_NUMBER 6

#define REFRESH_INTERVAL (3600 * 2)

- (void)updateDisplayView
{
    PPDebug(@"updateDisplayView");
    [[FeedService defaultService] getFeedList:FeedListTypeHot
                                       offset:0
                                        limit:TOP_DRAW_NUMBER + 3
                                     delegate:self];        
}

- (void)handleRefreshTimer:(NSTimer *)theTimer
{
    [self updateDisplayView];
}

- (CGFloat)imageWidth
{
    NSInteger spaceNumber = IMAGE_NUMBER_PER_PAGE - 1;
    CGFloat width = ((DISPLAY_SIZE.width - (SPACE_IMAGE * spaceNumber)) / IMAGE_NUMBER_PER_PAGE);
    return width;
}

- (CGFloat)imageHeight
{
    return (DISPLAY_SIZE.height);
}

- (void)handleTimer:(NSTimer *)theTimer
{
    NSInteger totalPage = self.displayScrollView.contentSize.width / DISPLAY_SIZE.width;
    if (totalPage > 1) {
        CGRect visibleFrame = CGRectZero;
        CGFloat offsetX = self.displayScrollView.contentOffset.x;
        NSInteger currentPage = offsetX / DISPLAY_SIZE.width;
        if (currentPage < totalPage - 1) {
            //next page
            offsetX += DISPLAY_SIZE.width;
            visibleFrame = self.displayScrollView.bounds;
            visibleFrame.origin.x = offsetX;
            
            [self.displayScrollView scrollRectToVisible:visibleFrame
                                               animated:YES];
        }else{
            //first page
            visibleFrame = self.displayScrollView.bounds;
            visibleFrame.origin.x = 0;
        }
        
        [self.displayScrollView scrollRectToVisible:visibleFrame
                                           animated:YES];

    }
}

- (void)startDisplayAnimation
{
    if (_scrollTimer == nil) {
        PPDebug(@"<startDisplayAnimation>");
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLL_INTERVAL target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];        
    }
}

- (void)clickDrawImage:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickDrawImage:)]) {
        UIButton *button = sender;
        NSInteger tag = button.tag;
        DrawFeed *feed = [self.feedList objectAtIndex:tag];
        [self.delegate homeHeaderPanel:self didClickDrawImage:feed];
    }
}

- (UIImageView *)imageForFeed:(DrawFeed *)feed index:(NSInteger)index
{
    if (feed && (feed.drawImage != nil || [feed.drawImageUrl length] != 0)) {
        CGRect frame = CGRectMake(0, 0, self.imageWidth, self.imageHeight);
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:frame]
                                  autorelease];
        if (feed.drawImage) {
            [imageView setImage:feed.drawImage];
        }else{
            [imageView setImageWithURL:[NSURL URLWithString:feed.drawImageUrl]];
        }
        
        NSInteger page = index / IMAGE_NUMBER_PER_PAGE;
        NSInteger number = index % IMAGE_NUMBER_PER_PAGE;
        
        CGFloat x = page * DISPLAY_SIZE.width;
        x += number * (self.imageWidth + SPACE_IMAGE);
        
        CGPoint origin = CGPointMake(x, 0);
        frame.origin = origin;
        imageView.frame = frame;
        
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:(self.imageWidth / 20)];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.frame = imageView.bounds;
        [button addTarget:self action:@selector(clickDrawImage:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:button];
        imageView.userInteractionEnabled = YES;
        return imageView;
    }
    return nil;
}



- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{

    if (resultCode == 0 && [feedList count] != 0) {

        //get Top 6 feed
        self.feedList = [NSMutableArray arrayWithArray:feedList];
        
        PPDebug(@"<didGetFeedList> ready to display images");
        [self.displayScrollView setHidden:NO];
        //display image.
        NSInteger i = 0;
        for (DrawFeed *feed in feedList) {
            UIImageView *iv = [self imageForFeed:feed index:i];
            if (iv) {
                ++i;
                [self.displayScrollView addSubview:iv];
            }
            if (i >= TOP_DRAW_NUMBER) {
                break;
            }
        }
        
        //update the scroll view frame
        NSInteger page = i / IMAGE_NUMBER_PER_PAGE;
        if (i % IMAGE_NUMBER_PER_PAGE != 0) {
            page ++;
        }
        self.displayScrollView.contentSize = CGSizeMake(DISPLAY_SIZE.width * page, DISPLAY_SIZE.height);
        [self startDisplayAnimation];
    }
}

#pragma mark - UpdateView

- (void)updateView
{
    self.backgroundColor = [UIColor clearColor];
    
    //avatar
    [self.avatar.layer setMasksToBounds:YES];
    [self.avatar.layer setCornerRadius:(self.avatar.frame.size.width / 2)];
    [self.avatar.layer setBorderWidth:3];
    UIColor *borderColor = [UIColor colorWithRed:131./225 green:200./225 blue:43./225 alpha:1];
    [self.avatar.layer setBorderColor:borderColor.CGColor];
    [self.nickName setTextColor:borderColor];
    
    UserManager *userManager = [UserManager defaultManager];
    if ([userManager avatarImage]) {
        [self.avatar setImage:[userManager avatarImage]];
    }else if([[userManager avatarURL] length] != 0){
        [self.avatar setImageWithURL:[NSURL URLWithString:[userManager avatarURL]]];
    }
    
    UIButton *mask = [UIButton buttonWithType:UIControlStateNormal];
    mask.frame = self.avatar.frame;
    [self addSubview:mask];
    [mask addTarget:self action:@selector(clickAvatarButton:) forControlEvents:UIControlEventTouchUpInside];
    
    //nick
    [self.nickName setText:userManager.nickName];

    //level
    NSInteger level = [[LevelService defaultService] level];
    [self.level setText:[NSString stringWithFormat:@"LV: %d",level]];
    
    //coin
    NSInteger coin = [[AccountService defaultService] getBalance];//[[AccountManager defaultManager] account].balance.intValue;
    NSString *coinString = [NSString stringWithFormat:@"x %d",coin];
    [self.coin setText:coinString];
    
    //charge button
    self.freeCoin.hidden = [ConfigManager wallEnabled] ? NO : YES;
    
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    [self.freeCoin setTitle:NSLS(@"kFreeCoin") forState:UIControlStateNormal];
    
    [self.displayScrollView setHidden:YES];
    

    //update display view.
    if (isDrawApp()) {
        [self updateDisplayView];
        [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(handleRefreshTimer:) userInfo:nil repeats:YES];
        
        self.displayBG.image = [[DrawImageManager defaultManager] drawHomeDisplayBG];
        [self.chargeButton.layer setTransform:CATransform3DMakeRotation(0.12, 0, 0, 1)];
    }else{
        self.displayBG.hidden = YES;
        DrawImageManager *imageManager = [DrawImageManager defaultManager];
        [self.chargeButton setBackgroundImage:[imageManager zjhHomeChargeBG]
                                     forState:UIControlStateNormal];
        [self.freeCoin setBackgroundImage:[imageManager zjhHomeFreeCoinBG]
                                 forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    PPRelease(_displayBG);
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_level);
    PPRelease(_chargeButton);
    PPRelease(_coin);
    PPRelease(_displayScrollView);
    PPRelease(_feedList);
    PPRelease(_freeCoin);
    [super dealloc];
}
- (IBAction)clickFreeCoinButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickFreeCoinButton:)]) {
        [self.delegate homeHeaderPanel:self didClickFreeCoinButton:sender];
    }
}

- (IBAction)clickChargeButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickChargeButton:)]) {
        [self.delegate homeHeaderPanel:self didClickChargeButton:sender];
    }
}
- (IBAction)clickAvatarButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickAvatarButton:)]) {
        [self.delegate homeHeaderPanel:self didClickAvatarButton:sender];
    }
}

@end
