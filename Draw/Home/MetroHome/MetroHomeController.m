//
//  MetroHomeController.m
//  Draw
//
//  Created by ChaoSo on 14-7-8.
//
//

#import "MetroHomeController.h"
#import "UserManager.h"
#import "UserTutorialMainController.h"
#import "UIViewController+CommonHome.h"
#import "MoreViewController.h"
#import "BillboardManager.h"
#import "ICETutorialController.h"
#import "GuidePageManager.h"
#import "ICETutorialController.h"
#import "ResultSharePageViewController.h"
#import "ResultShareAlertPageViewController.h"
#import "TipsPageViewController.h"
#import "SDWebImageManager.h"
#import "BulletinService.h"
#import "AudioManager.h"
#import "SuperHomeController.h"
#import "PPConfigManager.h"
#import "ContestService.h"
#import "WordManager.h"
#import "DrawRecoveryService.h"
#import "SDWebImageManager.h"

@interface MetroHomeController ()

@property(nonatomic, retain) NSTimer *statisTimer;

@end


@implementation MetroHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define TRENDS_BUTTON_TITLE_EDGEINSETS   (ISIPAD ? .0 : .0)
#define DOCUMENT_BUTTON_TITLE_EDGEINSETS (ISIPAD ? .0:  .0)
#define MESSAGE_BUTTON_TITLE_EDGEINSET   (ISIPAD ? .0 : .0)
#define MORE_BUTTON_TITLE_EDGEINSETS     (ISIPAD ? .0 : .0)
#define BOTTOM_BUTTON_MARGIN_HEIGHT (ISIPAD ? 50 : 38)

-(void)setButtonTitleBottom{
    
    [self.indexButton.imageView setImage:[UIImage imageNamed:@"dongtai.jpg"]];
    
    if([LocaleUtils isChina]||[LocaleUtils isChinese]){
        [self.indexButton.titleLabel setFont:AD_BOLD_FONT(13, 10)];
        [self.documentButton.titleLabel setFont:AD_BOLD_FONT(13, 10)];
        [self.messageButton.titleLabel setFont:AD_BOLD_FONT(13, 10)];
        [self.moreButton.titleLabel setFont:AD_BOLD_FONT(13,10)];
    }else{
        [self.indexButton.titleLabel setFont:AD_BOLD_FONT(9, 7)];
        [self.documentButton.titleLabel setFont:AD_BOLD_FONT(9, 7)];
        [self.messageButton.titleLabel setFont:AD_BOLD_FONT(9, 7)];
        [self.moreButton.titleLabel setFont:AD_BOLD_FONT(9,7)];
    }
    
    
    
    [self.indexButton setTitle:NSLS(@"kMetroIndexButton") forState:UIControlStateNormal];
    [self.documentButton setTitle:NSLS(@"kMetroDocumentButton") forState:UIControlStateNormal];
    [self.messageButton setTitle:NSLS(@"kMetroMessageButton") forState:UIControlStateNormal];
    [self.moreButton setTitle:NSLS(@"kMetroMoreButton") forState:UIControlStateNormal];
   
    [self.indexButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_MARGIN_HEIGHT, TRENDS_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.documentButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_MARGIN_HEIGHT, DOCUMENT_BUTTON_TITLE_EDGEINSETS, 0, 0)];
    [self.messageButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_MARGIN_HEIGHT, MESSAGE_BUTTON_TITLE_EDGEINSET, 0, 0)];
    [self.moreButton  setTitleEdgeInsets:UIEdgeInsetsMake(BOTTOM_BUTTON_MARGIN_HEIGHT, MORE_BUTTON_TITLE_EDGEINSETS, 0, 0)];
}
#pragma mark 使button对齐
-(void)buttonLayout
{
    CGRect tempFrame = self.indexButton.frame;
    
    tempFrame.size.width = 40;
    tempFrame.size.height = 5;
    PPDebug(@"<imageView.Size.Width>%d",self.bottomView.frame.size.width);
    self.indexButton.frame = tempFrame;
//    [self.indexButton.imageView];
}
- (void)startStatisticTimer
{
    if (self.statisTimer == nil){
        PPDebug(@"<startStatisticTimer>");
        self.statisTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];
    }
}

- (void)stopStatisticTimer
{
    if (self.statisTimer){
        PPDebug(@"<stopStatisticTimer>");
        if ([self.statisTimer isValid]){
            [self.statisTimer invalidate];
        }
        self.statisTimer = nil;
    }
}

#pragma mark - get && update statistic
- (void)handleStaticTimer:(NSTimer *)theTimer
{
    PPDebug(@"<handleStaticTimer>: get static");
    [[UserService defaultService] getStatistic:self];
}

- (void)didSyncStatisticWithResultCode:(int)resultCode
{
    if (resultCode == 0) {
        [self updateAllBadge];
    }
}

#define DEFAUT_IMAGE_NAME "dialogue@2x"
#define TEST_DATA_GALLERYIMAGE "http://58.215.184.18:8080/tutorial/image/GalleryImage2.jpg"

- (void)viewDidLoad
{
    self.view.backgroundColor = COLOR_GREEN;
    [self.documentBadge setNumber:0];
    
    [super viewDidLoad];
    
    [[BulletinService defaultService] syncBulletins:^(int resultCode) {
        [self updateAllBadge];
    }];
    
    // update avatar view
    [self registerNotificationWithName:NOTIFCATION_USER_DATA_CHANGE usingBlock:^(NSNotification *note) {
        PPDebug(@"recv NOTIFCATION_USER_DATA_CHANGE, update header view panel");
        [self updateAvatarView];
        [self updateAllBadge];
    }];
    
    // update background view
    [self registerNotificationWithName:UPDATE_HOME_BG_NOTIFICATION_KEY usingBlock:^(NSNotification *note) {
        [self updateBGImageView];
    }];

    [self updateBGImageView];
    [self startAudioManager];
    
    [self registerUIApplicationNotification];
    
//    [self performSelector:@selector(updateRecoveryDrawCount) withObject:nil afterDelay:0.5f];
    
    
//    [[GuessService defaultService] getTodayGuessContestInfoWithDelegate:self];

    [self setBackground];
    // Do any additional setup after loading the view from its nib.

    
    [self setGalleryView];
   
    //用户头像
    [self updateAvatarView];
    self.avatarView.delegate = self;
    
    [self setButtonTitleBottom];
#pragma mark 调用buttonLayout
    [self buttonLayout];
    
    //Autolayout 适配ios6 ios7
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.galleryView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.topView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:0];
    
    NSLayoutConstraint* constraint2 = [NSLayoutConstraint constraintWithItem:self.topView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:STATUSBAR_DELTA];
    
    [self.view addConstraint:constraint];
    [self.view addConstraint:constraint2];
    
}

- (void)updateBGImageView
{
    
}

- (void)updateAvatarView
{
    UserManager* userManager = [UserManager defaultManager];
    
    // set avatar
    [self.avatarView setAvatarUrl:[userManager avatarURL]
                           gender:[userManager gender]
                   useDefaultLogo:NO];
    
    // set nick name
    NSString *name = [userManager nickName];
    [_topNameLable setText:name];
    [_topNameLable setFont:AD_FONT(20, 15)];
    [_topNameLable setTextColor:COLOR_BROWN];
    [_topNameButton setTitle:name forState:UIControlStateNormal];
    [_topNameButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [_topNameButton.titleLabel setFont:AD_FONT(20, 15)];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [[UserService defaultService] getStatistic:self];
    [self startStatisticTimer];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopStatisticTimer];
    
    [self hideActivity];
    [super viewDidDisappear:animated];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// TODO check
- (void)galleryClick:(id)sender
{
    [[self.bbList objectAtIndex:0] clickAction:self];
    PPDebug(@"<click_gallery_image>button_tag=%d",index);
}



#define TEST_DATA 5
-(void)setBadgeView{
    [self.indexBadge setNumber:TEST_DATA];
    [self.documentBadge setNumber:TEST_DATA];
    [self.messageBadge setNumber:TEST_DATA];
    [self.moreBadge setNumber:TEST_DATA];
    [self.anounceBadge setNumber:TEST_DATA];
}

- (void)updateBadgeTimeline:(int)count
{
    [self.indexBadge setNumber:count];
}

- (void)updateBadgeChat:(int)count
{
    [self.messageBadge setNumber:count];
}

//- (void)updateBadgeDraft:(int)count
//{
//    [self.documentBadge setNumber:count];
//}

- (void)updateBadgeMore:(int)count
{
    [self.moreBadge setNumber:count];
}

- (void)updateBulletinBadge:(int)count
{
    [self.anounceBadge setNumber:count];
}

- (void)updateBadgeBBS:(int)count
{
    // TODO
}

- (IBAction)goToLearning:(id)sender{
    [self enterLearnDraw];
}

//主页背景
#define GALLERY_BACKGROUND_Y (ISIPAD ? 69:41)
- (void)setBackground
{
    
    UIImage *galleryBackground = [UIImage imageNamed:@"gonggaolan.png"];
    UIColor *color = [[UIColor alloc] initWithPatternImage:galleryBackground];
    
    CGRect frame = CGRectMake(0, GALLERY_BACKGROUND_Y, self.galleryView.frame.size.width, self.galleryView.frame.size.height);
    UIView *bg = [[UIView alloc] initWithFrame:frame];
    [bg setBackgroundColor:color];
    [color release];
    
    self.galleryView.backgroundColor = [UIColor clearColor];
    [self.topView insertSubview:bg atIndex:0];
    [bg release];
    UIImage *bottomBackground = [UIImage imageNamed:@"neironglan yu caidanlan.png"];
    [self.bottomBackground setBackgroundColor:[UIColor clearColor]];
    [self.bottomBackground setImage:bottomBackground];
    CGFloat mainScreenHeight = [[UIScreen mainScreen] bounds].size.height;
    if(!ISIPAD){
        NSLayoutConstraint* constraint = nil;
        if(mainScreenHeight == 480){
            constraint = [NSLayoutConstraint constraintWithItem:self.bottomBackground
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.mainView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.0
                                                       constant:-5];
        }else{
            constraint = [NSLayoutConstraint constraintWithItem:self.bottomBackground
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.mainView
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.0
                                                       constant:-10];
        }
        [self.view addConstraint:constraint];
    }
}
    
#pragma mark click
- (IBAction)goTolearning:(id)sender {
}

- (IBAction)goToBBS:(id)sender
{
    [self enterBBS];
}

- (IBAction)goToDraw:(id)sender
{
#ifdef DEBUG
    [self enterOfflineDrawWithMenu];
#else
    [self enterOfflineDraw];
#endif
}

- (IBAction)goToOpus:(id)sender
{
    [self enterOpusClass];
}

- (IBAction)goToIndexController:(id)sender
{
    [self enterTimeline];
}

- (IBAction)goToDocumentController:(id)sender
{
    [self enterDraftBox];
}

- (IBAction)goToMessageController:(id)sender
{
    [self enterChat];
}

- (IBAction)goToMoreController:(id)sender
{
    MoreViewController *more = [[MoreViewController alloc] init];
    [self.navigationController pushViewController:more animated:YES];
    [more release];
}


-(IBAction)goToAnnounce:(id)sender
{
    [self showBulletinView];
}

-(IBAction)goToUserDetail:(id)sender
{
    [self enterUserDetail];
}





#pragma mark - Avatart View Delegate

- (void)didClickOnAvatar:(NSString *)userId
{
    [self enterUserDetail];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    // Release any cached data, images, etc that aren't in use.
    [[SDWebImageManager sharedManager].imageCache clearMemory];
}

#pragma mark -

// 设置Gallery
#define IMAGE_FRAME_X (ISIPAD ? 26:11)
#define IMAGE_FRAME_Y (ISIPAD ? 24:15)
#define IMAGE_FRAME_WIDTH (ISIPAD ? 716:298)
#define IMAGE_FRAME_HEIGHT (ISIPAD ? 250:120)
#define DEFAULT_GALLERY_IMAGE @"daguanka"

-(void)setGalleryView{
    
    BillboardManager *bbManager = [BillboardManager defaultManager];
    self.bbList = bbManager.bbList;

    //默认图片
    UIImage *image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE];
    [self.galleryImageView setImage:image];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
        for(Billboard *bb in _bbList){

            UIImage *image = [bbManager getImage:bb];
            
            //添加到第三方框架
            SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:bb.index] autorelease];
            
            [itemList addObject:item];            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //新建滚动展览
            SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(IMAGE_FRAME_X, IMAGE_FRAME_Y, IMAGE_FRAME_WIDTH ,IMAGE_FRAME_HEIGHT)
                                                                            delegate:self
                                                    hasPageControllerBackgroundColor:NO
                                                                     focusImageItems:itemList, nil];
            [self.galleryView addSubview:imageFrame];
            [self.galleryView bringSubviewToFront:imageFrame];
            [imageFrame release];
        });
    });
    

}
-(void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item{
    NSLog(@"%@", item.title);
}

//根据字符串反射到方法
-(void)clickActionDelegate:(int)index{
    NSInteger count = [self.bbList count];
    if(index >= count){
        return;
    }
    [[self.bbList objectAtIndex:index] clickAction:self];
}

- (void)updateAllBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    
    [self updateBadgeChat:manager.messageCount];
    [self updateBadgeBBS:manager.bbsActionCount];
    
    long timelineCount = manager.timelineOpusCount +
                            manager.timelineGuessCount +
                            manager.commentCount +
                            manager.drawToMeCount;
    [self updateBadgeTimeline:timelineCount];
    
    int moreCount = [manager newContestCount] + [manager groupNoticeCount];
    [self updateBadgeMore:moreCount];
    
    [self updateBulletinBadge:[manager bulletinCount]];
    
    // TODO
    //    [self updateBadgeBBS:HomeMenuTypeDrawFriend badge:manager.fanCount];
}



- (void)dealloc {
    [_galleryView release];
    [_galleryImageView release];
    [_topView release];
    [_topNameLable release];
    [_topAnnounceView release];
    [_topAnnounceButton release];
    [_avatarView release];
    [_paintingView release];
    [_paintingViewButton release];
    [_learningView release];
    [_learningViewButton release];
    [_mainView release];
    [_bottomView release];
    [_indexButton release];
    [_documentButton release];
    [_messageButton release];
    [_moreButton release];
    [_topNameButton release];
    [_bottomBackground release];
    [_indexBadge release];
    [_documentBadge release];
    [_messageBadge release];
    [_moreBadge release];
    [_anounceBadge release];
    [_galleryButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setGalleryView:nil];
    [self setGalleryImageView:nil];
    [self setTopView:nil];
    [self setTopNameLable:nil];
    [self setTopAnnounceView:nil];
    [self setTopAnnounceButton:nil];
    [self setAvatarView:nil];
    [self setPaintingView:nil];
    [self setPaintingViewButton:nil];
    [self setLearningView:nil];
    [self setLearningViewButton:nil];
    [self setLearningView:nil];
    [self setLearningViewButton:nil];
    [self setMainView:nil];
    [self setBottomView:nil];
    [self setIndexButton:nil];
    [self setDocumentButton:nil];
    [self setMessageButton:nil];
    [self setMoreButton:nil];
    [self setTopNameButton:nil];
    [self setBottomBackground:nil];
    [self setIndexBadge:nil];
    [self setDocumentBadge:nil];
    [self setMessageBadge:nil];
    [self setMoreBadge:nil];
    [self setAnounceBadge:nil];
    [self setGalleryButton:nil];
    [super viewDidUnload];
}

- (void)registerUIApplicationNotification
{
    
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification
                            usingBlock:^(NSNotification *note) {
    }];
    
    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification
                            usingBlock:^(NSNotification *note) {
        
        [[BulletinService defaultService] syncBulletins:^(int resultCode) {
            PPDebug(@"sync bulletin done, update header view panel");
            [self updateBulletinBadge];
        }];
    }];
    
    [self registerNotificationWithName:NOTIFCATION_CONTEST_DATA_CHANGE usingBlock:^(NSNotification *note) {
        PPDebug(@"recv NOTIFCATION_CONTEST_DATA_CHANGE, update header view panel");
        [self updateAllBadge];
    }];
}

//- (void)updateRecoveryDrawCount
//{
//    NSUInteger count = [[DrawRecoveryService defaultService] recoveryDrawCount];
//    [self updateBadgeDraft:count];
//    [[StatisticManager defaultManager] setRecoveryCount:count];
//}

- (void)updateBulletinBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    [self updateBulletinBadge:[manager bulletinCount]];
}

- (void)enterShareFromWeixin
{
//    if ([self isRegistered] == NO) {
//        [self toRegister];
//    } else {
//        ShareController* share = [[ShareController alloc] init ];
//        [share setFromWeiXin:YES];
//        [self.navigationController pushViewController:share animated:YES];
//        [share release];
//    }
}

@end
