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
#import "BrickView.h"

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
    }];

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

    [_bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_topView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_galleryView setTranslatesAutoresizingMaskIntoConstraints:NO];


    [self setAllViewConstraints];
    if(isIPad){
        [self setMainBoxView_iPad];
    }else{
        [self setMainBoxView];
    }
    [self showGuidePage];
    
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
    
//    [self updateAllBadge];
    
    if ([[UserManager defaultManager] hasXiaojiNumber] == NO){
        [self showGuidePage];
    }
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
-(void)updateAvatarBadge:(int)count{
    [self.avatarBadgeView setNumber:count];
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
    [self updateAllBadge];
}

-(IBAction)goToUserDetail:(id)sender
{
    [self enterUserDetail];
}





#pragma mark - Avatart View Delegate

- (void)didClickOnAvatar:(NSString *)userId
{
    [self enterUserDetail];
    [self updateAvatarBadge:0];
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
#define IMAGE_FRAME_X (ISIPAD ? 31:11)
#define IMAGE_FRAME_Y (ISIPAD ? 44:16)
#define IMAGE_FRAME_WIDTH (ISIPAD ? 706:298)
#define IMAGE_FRAME_HEIGHT (ISIPAD ? 250:120)
#define DEFAULT_GALLERY_IMAGE @"daguanka"

-(void)setGalleryView{
    
    BillboardManager *bbManager = [BillboardManager defaultManager];
    self.bbList = bbManager.bbList;


    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
        for(Billboard *bb in _bbList){

            UIImage *image = [bbManager getImage:bb];
            if(image==nil){
                //默认图片
                image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE];
                [self.galleryImageView setImage:image];
            }
            
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
                            manager.timelineConquerCount +
                            manager.commentCount +
                            manager.drawToMeCount;

    [self updateBadgeTimeline:timelineCount];
    
    int moreCount = [MoreViewController totalMoreBadge];
    [self updateBadgeMore:moreCount];
    
    [self updateBulletinBadge:[manager bulletinCount]];
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
    [_forumView release];
    [_amazingOpusView release];
    [_avatarBadgeView release];
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
    [self setForumView:nil];
    [self setAmazingOpusView:nil];
    [self setAvatarBadgeView:nil];
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

- (void)updateBulletinBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    [self updateBulletinBadge:[manager bulletinCount]];
}

#pragma mark - constraint
-(void)setAllViewConstraints{
    
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_bottomView, _mainView,_topView,_galleryView);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [_bottomView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_topView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_galleryView setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    NSString *topViewConstraints = @"V:[_galleryView(>=140)]-0-[_mainView(>=140)]";
    NSString *bottomViewConstrains = @"V:[_bottomView(==49)]-0-|";
    
    
    if(ISIOS7){
        NSString *topView = @"V:|-20-[_topView(==40)]";
        [constraints addObject:topView];
    }else{
        NSString *topView = @"V:|-0-[_topView(==40)]";
        [constraints addObject:topView];
    }
//    [constraints addObject:topViewConstraints];
    [constraints addObject:bottomViewConstrains];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:views]];
    }

    
    
}

-(void)setMainBoxView{
    
    CGFloat height = 205;
    if(ISIPHONE5){
        height = 292;
    }
    
    CGFloat bigViewHeight = height * 0.618f;
    CGFloat smallViewHeight = height - bigViewHeight;
    
    UIImage *paintingImage = [UIImage imageNamed:@"huahua"];
    BrickView *paintingView = [[[BrickView alloc] initWithFrame:self.paintingView.bounds title:@"画画" imageTitle:@"Painting" image:paintingImage] autorelease];
    
    UIImage *learningImage = [UIImage imageNamed:@"xuehuahua"];
    BrickView *learningView = [[[BrickView alloc] initWithFrame:self.learningView.bounds title:@"学画画" imageTitle:@"Learning" image:learningImage] autorelease];
    
    UIImage *forumImage = [UIImage imageNamed:@"luntan"];
    BrickView *forumView = [[[BrickView alloc] initWithFrame:self.forumView.bounds title:@"论坛" imageTitle:@"Forum" image:forumImage] autorelease];
    
    UIImage *amazingImage = [UIImage imageNamed:@"jingcaizuopin"];
    BrickView *amazingOpusView = [[[BrickView alloc] initWithFrame:self.amazingOpusView.bounds title:@"精彩作品" imageTitle:@"Gallery" image:amazingImage] autorelease];
    
    
    [paintingView setBackgroundColor:[UIColor colorWithRed:0.757f green:0.565f blue:0.965f alpha:1.0f]];
    [learningView setBackgroundColor:[UIColor colorWithRed:0.984f green:0.431f blue:0.588f alpha:1.0f]];
    [forumView setBackgroundColor:[UIColor colorWithRed:0.459f green:0.784f blue:0.965f alpha:1.0f]];
    [amazingOpusView setBackgroundColor:[UIColor colorWithRed:0.553f green:0.612f blue:0.98f alpha:1.0f]];
    
    [self.mainView addSubview:paintingView];
    [self.mainView addSubview:learningView];
    [self.mainView addSubview:forumView];
    [self.mainView addSubview:amazingOpusView];
    
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_mainView,paintingView,learningView, forumView, amazingOpusView);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [paintingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [learningView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forumView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [amazingOpusView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //Horizone
    NSString *paintAndLearnViewHorizone = @"H:|-9.5-[paintingView]-7-[learningView(==190)]-9.5-|";
    NSString *forumAndAmazingViewHorizone = @"H:|-9.5-[forumView]-8-[amazingOpusView(==190)]-9.5-|";
    [constraints addObject:paintAndLearnViewHorizone];
    [constraints addObject:forumAndAmazingViewHorizone];
    
    
    
    NSString *paintAndForumViewVertical = [NSString stringWithFormat:@"V:|-5-[paintingView(==%f)]-5-[forumView(==%f)]-5-|",bigViewHeight,smallViewHeight];
    
    NSString *learnAndAmazingViewVertical = [NSString stringWithFormat:@"V:|-5-[learningView(==%f)]-5-[amazingOpusView(==%f)]-5-|",bigViewHeight,smallViewHeight];
    
    [constraints addObject:paintAndForumViewVertical];
    [constraints addObject:learnAndAmazingViewVertical];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:views]];
    }
    
   
    [self setMainViewListening:paintingView learningView:learningView forumView:forumView amazingOpusView:amazingOpusView];
    
    
}

-(void)setMainBoxView_iPad{
    
    CGFloat height = 595-40;
    
    CGFloat bigViewHeight = height * 0.618f;
    CGFloat smallViewHeight = height - bigViewHeight;
    
    UIImage *paintingImage = [UIImage imageNamed:@"huahua"];
    BrickView *paintingView = [[[BrickView alloc] initWithFrame:self.paintingView.bounds title:@"画画" imageTitle:@"Painting" image:paintingImage] autorelease];
    
    UIImage *learningImage = [UIImage imageNamed:@"xuehuahua"];
    BrickView *learningView = [[[BrickView alloc] initWithFrame:self.learningView.bounds title:@"学画画" imageTitle:@"Learning" image:learningImage] autorelease];
    
    UIImage *forumImage = [UIImage imageNamed:@"luntan"];
    BrickView *forumView = [[[BrickView alloc] initWithFrame:self.forumView.bounds title:@"论坛" imageTitle:@"Forum" image:forumImage] autorelease];
    
    UIImage *amazingImage = [UIImage imageNamed:@"jingcaizuopin"];
    BrickView *amazingOpusView = [[[BrickView alloc] initWithFrame:self.amazingOpusView.bounds title:@"精彩作品" imageTitle:@"Gallery" image:amazingImage] autorelease];
    
    
    
    [paintingView setBackgroundColor:[UIColor colorWithRed:0.757f green:0.565f blue:0.965f alpha:1.0f]];
    [learningView setBackgroundColor:[UIColor colorWithRed:0.984f green:0.431f blue:0.588f alpha:1.0f]];
    [forumView setBackgroundColor:[UIColor colorWithRed:0.459f green:0.784f blue:0.965f alpha:1.0f]];
    [amazingOpusView setBackgroundColor:[UIColor colorWithRed:0.553f green:0.612f blue:0.98f alpha:1.0f]];
    
    
    [self.mainView addSubview:paintingView];
    [self.mainView addSubview:learningView];
    [self.mainView addSubview:forumView];
    [self.mainView addSubview:amazingOpusView];
    
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_mainView,paintingView,learningView, forumView, amazingOpusView);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [paintingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [learningView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forumView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [amazingOpusView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //Horizone
    NSString *paintAndLearnViewHorizone = @"H:|-28-[paintingView(==240)]-10-[learningView(==452)]-28-|";
    NSString *forumAndAmazingViewHorizone = @"H:|-28-[forumView(==240)]-10-[amazingOpusView(==452)]-28-|";
    [constraints addObject:paintAndLearnViewHorizone];
    [constraints addObject:forumAndAmazingViewHorizone];
    
    
    
    NSString *paintAndForumViewVertical = [NSString stringWithFormat:@"V:|-10-[paintingView(==%f)]-20-[forumView(==%f)]-10-|",bigViewHeight,smallViewHeight];
    
    NSString *learnAndAmazingViewVertical = [NSString stringWithFormat:@"V:|-10-[learningView(==%f)]-20-[amazingOpusView(==%f)]-10-|",bigViewHeight,smallViewHeight];
    
    [constraints addObject:paintAndForumViewVertical];
    [constraints addObject:learnAndAmazingViewVertical];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:views]];
    }
    
    [self setMainViewListening:paintingView learningView:learningView forumView:forumView amazingOpusView:amazingOpusView];
    
}

#pragma mark - Listen
-(void)setListenInView:(UIView*)view selector:(SEL)selector{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [view addGestureRecognizer:singleTap];
}

-(void)setMainViewListening:(UIView*)paintingView learningView:(UIView*)learningView forumView:(UIView*)forumView amazingOpusView:(UIView*)amazingOpusView{
    
    //Listen
    paintingView.userInteractionEnabled = YES;
    learningView.userInteractionEnabled = YES;
    forumView.userInteractionEnabled = YES;
    amazingOpusView.userInteractionEnabled = YES;
    
    [self setListenInView:paintingView selector:@selector(goToDraw:)];
    [self setListenInView:learningView selector:@selector(goToLearning:)];
    [self setListenInView:forumView selector:@selector(goToBBS:)];
    [self setListenInView:amazingOpusView selector:@selector(goToOpus:)];
}




@end
