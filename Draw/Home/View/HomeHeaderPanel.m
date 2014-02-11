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
#import "PPConfigManager.h"
#import "BulletinView.h"
#import "FriendController.h"
#import "StatisticManager.h"
#import "UIViewUtils.h"
#import "ShareImageManager.h"
#import "UIImageView+Extend.h"
#import "StringUtil.h"

@interface HomeHeaderPanel ()<AvatarViewDelegate>
{
    NSMutableArray *_feedList;
    NSTimer *_scrollTimer;
}
@property (retain, nonatomic) IBOutlet UIImageView *displayBG;
@property (retain, nonatomic) IBOutlet AvatarView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *level;
@property (retain, nonatomic) IBOutlet UIButton *chargeButton;
@property (retain, nonatomic) IBOutlet UIButton *bulletinButton;
@property (retain, nonatomic) IBOutlet UILabel *coin;
@property (retain, nonatomic) IBOutlet UIScrollView *displayScrollView;
@property (retain, nonatomic) IBOutlet UIButton *freeCoin;
@property (retain, nonatomic) IBOutlet UIButton *bulletinBadge;
@property (retain, nonatomic) IBOutlet UILabel *ingotLabel;
@property (retain, nonatomic) IBOutlet UILabel *friendCountLabel;
@property (retain, nonatomic) IBOutlet UIButton *friendBadgeButton;
@property (retain, nonatomic) IBOutlet UIImageView *coinCountBackgroundImageView;
@property (retain, nonatomic) IBOutlet UIImageView *friendCountBackgroundImageView;

@property (retain, nonatomic) NSMutableArray *feedList;

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

#define TOP_DRAW_NUMBER [PPConfigManager getHomeDisplayOpusNumber]

#define REFRESH_INTERVAL (3600 * 2)

- (void)updateDisplayView
{
    PPDebug(@"updateDisplayView");
    
    int feedListType = FeedListTypeHot;
    HotIndexType indexType = [[UserManager defaultManager] hotControllerIndex];
    if (indexType == HotLatestIndex){
        feedListType = FeedListTypeLatest;
    }
    
    [[FeedService defaultService] getFeedList:feedListType
                                       offset:0
                                        limit:[PPConfigManager getHotOpusCountOnce]
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
            
            UIImage* placeHolder = [[ShareImageManager defaultManager] unloadBg];
            [imageView setImageWithUrl:[feed thumbURL] placeholderImage:placeHolder showLoading:NO animated:YES];
            
            //[imageView setImageWithURL:[feed thumbURL]];
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


- (void)clearOldDisplayImages
{
    for (UIImageView *imageView in [self.displayScrollView subviews]) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

- (void)showFreed
{
    [self.displayScrollView setHidden:NO];
    [self clearOldDisplayImages];
    NSInteger i = 0;
    
    if ([_feedList count] > 0) {
        for (DrawFeed *feed in _feedList) {
            UIImageView *iv = [self imageForFeed:feed index:i];
            if (iv) {
                iv.contentMode = UIViewContentModeScaleAspectFill;
                ++i;
                [self.displayScrollView addSubview:iv];
            }
            if (i >= TOP_DRAW_NUMBER) {
                break;
            }
        }
    } else {
        for (; i < IMAGE_NUMBER_PER_PAGE; i++) {
            CGFloat x = i * ([self imageWidth]  + SPACE_IMAGE);
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:[[ShareImageManager defaultManager] unloadBg]] autorelease];
            [imageView.layer setCornerRadius:(self.imageWidth / 20)];
            imageView.frame = CGRectMake(x, 0, [self imageWidth], [self imageWidth]);
            [self.displayScrollView addSubview:imageView];
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

- (void)didGetFeedList:(NSArray *)feedList
          feedListType:(FeedListType)type
            resultCode:(NSInteger)resultCode
{

    if (resultCode == 0 && [feedList count] != 0) {
        //get Top 6 feed
        if (self.feedList != feedList) {
            self.feedList = [NSMutableArray arrayWithArray:feedList];
        } 
    } else {
        NSArray *list = [[FeedService defaultService] getCachedFeedList:FeedListTypeHot];
        self.feedList = [NSMutableArray arrayWithArray:list];
    }
    
    [self showFreed];
}

#define MAX_COUNT_BG_SIZE  ([DeviceDetection isIPAD] ? CGSizeMake(160, 36) : CGSizeMake(80, 18))
#define MIN_COUNT_BG_SIZE  ([DeviceDetection isIPAD] ? CGSizeMake(80, 36) : CGSizeMake(40, 18))

- (void)didGetFanCount:(NSInteger)fanCount
           followCount:(NSInteger)followCount
            blackCount:(NSInteger)blackCount
            resultCode:(NSInteger)resultCode
{    
    self.friendCountLabel.text = [NSString stringWithFormat:@"%d", fanCount];
    
    //change bg size
    CGSize size = [_friendCountLabel.text sizeWithMyFont:_friendCountLabel.font];
    if (size.width > MAX_COUNT_BG_SIZE.width) {
        size = MAX_COUNT_BG_SIZE;
    }
    if (size.width < MIN_COUNT_BG_SIZE.width) {
        size = MIN_COUNT_BG_SIZE;
    }
    [self.friendCountBackgroundImageView updateWidth:size.width];
    self.friendCountBackgroundImageView.center = self.friendCountLabel.center;
}

#pragma mark - UpdateView

- (void)updateView
{
    self.backgroundColor = [UIColor clearColor];
    
    if (isSingApp()) {
//        [self.avatar setAsRound];
        [self.avatar.layer setBorderWidth:6];
        [self.avatar.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.nickName setTextColor:[UIColor blackColor]];
    } else {
//        [self.avatar setAsRound];
        [self.avatar.layer setBorderWidth:3];
        UIColor *borderColor = [UIColor colorWithRed:108/225 green:223./225 blue:187./225 alpha:1];
        [self.avatar.layer setBorderColor:borderColor.CGColor];
        [self.nickName setTextColor:borderColor];
    }
    
    UserManager *userManager = [UserManager defaultManager];
    
    [self.avatar setAvatarUrl:[userManager avatarURL] gender:[userManager boolGender]];
    self.avatar.delegate = self;
    
    
    //nick
    [self.nickName setText:userManager.nickName];

    //level
    NSInteger level = [[LevelService defaultService] level];
    [self.level setText:[NSString stringWithFormat:@"LV: %d",level]];
    
    //coin
    NSInteger coin = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin];
    NSInteger ingot = [[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyIngot];
    
    NSString *coinString = nil;
    if (isSingApp()) {
        coinString = [NSString stringWithFormat:@"%d",coin];
    } else {
        coinString = [NSString stringWithFormat:@"x %d",coin];
    }
    [self.coin setText:coinString];
    
    NSString *ingotString = [NSString stringWithFormat:@"x %d",ingot];
    [self.ingotLabel setText:ingotString];
        
    [self.chargeButton setTitle:NSLS(@"kCharge") forState:UIControlStateNormal];
    [self.bulletinButton setTitle:NSLS(@"kBulletin") forState:UIControlStateNormal];
    [self.freeCoin setTitle:NSLS(@"kFreeCoins") forState:UIControlStateNormal];
    
    [self.displayScrollView setHidden:YES];
    

    //update display view.
    if (isDrawApp()) {
        if ([self.feedList count] <= 0) {
            [self updateDisplayView];
            [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(handleRefreshTimer:) userInfo:nil repeats:YES];
        }else{
            [self didGetFeedList:self.feedList feedListType:0 resultCode:0];
        }
        self.displayBG.image = [[DrawImageManager defaultManager] drawHomeDisplayBG];
        [self showFreed];
    }else{
        self.displayBG.hidden = YES;
        DrawImageManager *imageManager = [DrawImageManager defaultManager];

        [self.chargeButton setBackgroundImage:[imageManager zjhHomeFreeCoinBG]
                                     forState:UIControlStateNormal];

        [self.freeCoin setBackgroundImage:[imageManager zjhHomeFreeCoinBG]
                                 forState:UIControlStateNormal];
    }
    
    if (isSingApp()) {
        //change coin bg size
        CGSize size = [_coin.text sizeWithMyFont:_coin.font];
        if (size.width > MAX_COUNT_BG_SIZE.width) {
            size = MAX_COUNT_BG_SIZE;
        }
        if (size.width < MIN_COUNT_BG_SIZE.width) {
            size = MIN_COUNT_BG_SIZE;
        }
        [self.coinCountBackgroundImageView updateWidth:size.width];
        self.coinCountBackgroundImageView.center = self.coin.center;
        
        //get fan count
        [[FriendService defaultService] getRelationCount:self];
        if ([StatisticManager defaultManager].fanCount > 0) {
            self.friendBadgeButton.hidden = NO;
            [self.friendBadgeButton setTitle:[NSString stringWithFormat:@"%d", (int)[StatisticManager defaultManager].fanCount] forState:UIControlStateNormal];
        } else {
            self.friendBadgeButton.hidden = YES;
        }
    }
}

- (void)dealloc {
    PPRelease(_displayBG);
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_level);
    PPRelease(_chargeButton);
    PPRelease(_bulletinButton);
    PPRelease(_coin);
    PPRelease(_displayScrollView);
    PPRelease(_feedList);
    PPRelease(_freeCoin);
    [_ingotLabel release];
    [_friendCountLabel release];
    [_friendBadgeButton release];
    [_coinCountBackgroundImageView release];
    [_friendCountBackgroundImageView release];
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

- (void)didClickOnAvatar:(NSString*)userId{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickAvatarButton:)]) {
        [self.delegate homeHeaderPanel:self didClickAvatarButton:nil];
    }
} 

- (IBAction)clickBulletinButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickBulletinButton:)]) {
        [self.delegate homeHeaderPanel:self didClickBulletinButton:sender];
    }
    [self updateBulletinBadge:0];
}

- (IBAction)clickFriendButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickFriendButton:)]) {
        [self.delegate homeHeaderPanel:self didClickFriendButton:sender];
    }
    
    self.friendBadgeButton.hidden = YES;
}

- (void)updateBulletinBadge:(int)count
{
    [self.bulletinBadge setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
    if (count > 0) {
        [self.bulletinBadge setHidden:NO];
    } else {
        [self.bulletinBadge setHidden:YES];
    }
}

- (void)viewDidAppear
{
    PPDebug(@"DidAppear, DEFAULT IMPLEMENTATION");    
}

- (void)viewDidDisappear
{
    PPDebug(@"Disappear, DEFAULT IMPLEMENTATION");
}

@end
