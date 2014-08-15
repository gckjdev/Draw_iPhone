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
#import "UIImageUtil.h"

@interface MetroHomeController ()

@property(nonatomic, retain) NSTimer *statisTimer;
@property(nonatomic, retain) BrickView *bbsForumView;

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



#pragma mark 使button对齐
-(void)buttonLayout
{
    CGRect tempFrame = self.indexButton.frame;
    
    tempFrame.size.width = 40;
    tempFrame.size.height = 5;
    PPDebug(@"<imageView.Size.Width>%d",tempFrame.size.width);
    PPDebug(@"<imageView.Size.Width>%d",tempFrame.size.height);
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
    [self.moreBadge.titleLabel setFont:AD_BOLD_FONT(12, 10)];
    [self.indexBadge.titleLabel setFont:AD_BOLD_FONT(12, 10)];
    [self.documentBadge.titleLabel setFont:AD_BOLD_FONT(12, 10)];
    [self.messageBadge.titleLabel setFont:AD_BOLD_FONT(12, 10)];
    
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

//    [self setButtonTitleBottom];
    [self setListenInView:self.topAnnounceView selector:@selector(goToAnnounce:)];
    [self.topAnnounceButton setUserInteractionEnabled:NO];
    
#pragma mark 调用buttonLayout
    [self buttonLayout];


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
    [self setBottomViewButton];
    [self showGuidePage];
    
}

- (void)updateAvatarView
{
    UserManager* userManager = [UserManager defaultManager];
    
    // set avatar
    [self.avatarView setAvatarUrl:[userManager avatarURL]
                           gender:[userManager boolGender]
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
    
//    [self updateAllBadge:nil];
    
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
    [self.indexBadge.titleLabel setFont:AD_BOLD_FONT(13, 10)];
    [self.documentBadge setNumber:TEST_DATA];
    [self.messageBadge setNumber:TEST_DATA];
    [self.moreBadge setNumber:TEST_DATA];
    [self.moreBadge.titleLabel setFont:AD_BOLD_FONT(3, 2)];
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
#define DEFAULT_GALLERY_IMAGE_CN @"defaultBillBoard@2x.jpg"
#define DEFAULT_GALLERY_IMAGE_EN @"defaultBillBoard_en@2x.jpg"

-(void)setGalleryView{
    
    BillboardManager *bbManager = [BillboardManager defaultManager];
    self.bbList = bbManager.bbList;


    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSMutableArray *itemList = [[[NSMutableArray alloc] init] autorelease];
      
        for(Billboard *bb in _bbList){

            UIImage *image = [bbManager getImage:bb];
            if(image==nil){
                //默认图片
                if ([LocaleUtils isChinese]){
                    image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE_CN];
                }
                else{
                    image = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE_EN];
                }
                
                [self.galleryImageView setImage:image];
            }
            
            //添加到第三方框架
            SGFocusImageItem *item = [[[SGFocusImageItem alloc] initWithTitle:@"" image:image tag:bb.index] autorelease];
            
            [itemList addObject:item];            
        }
      
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //新建滚动展览
            CGRect frame = CGRectMake(IMAGE_FRAME_X, IMAGE_FRAME_Y, IMAGE_FRAME_WIDTH ,IMAGE_FRAME_HEIGHT);
            SGFocusImageFrame *imageFrame = [[SGFocusImageFrame alloc] initWithFrame:frame
                                                                            delegate:self
                                                                     focusImageItems:itemList];
            [imageFrame setAlignment:SMPageControlAlignmentRight];
            [self.galleryView addSubview:imageFrame];
            [self.galleryView bringSubviewToFront:imageFrame];
            [imageFrame release];
            
            if([_bbList count]<=0){
                UIImageView *image = [[UIImageView alloc]initWithFrame:frame];
                
                //默认图片
                UIImage* defaultImage = nil;
                if ([LocaleUtils isChinese]){
                    defaultImage = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE_CN];
                }
                else{
                    defaultImage = [UIImage imageNamed:DEFAULT_GALLERY_IMAGE_EN];
                }
                
                [image setImage:defaultImage];
                [self.galleryView addSubview:image];
                [self.galleryView bringSubviewToFront:image];
                [image release];
                
            }
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
    
    if (self.bbsForumView != nil){
        if (manager.bbsActionCount == 0){
            [self.bbsForumView setBottomLabelText:@"Forum" color:COLOR_WHITE];
            [self.bbsForumView stopAnimationOnImage];
        }
        else{
            [self.bbsForumView setBottomLabelText:[NSString stringWithFormat:@"Forum (%ld)",manager.bbsActionCount] color:COLOR_WHITE];
            
            [self.bbsForumView startAnimationOnImage:[NSArray arrayWithObjects:
                                                        [UIImage imageNamed:@"1.gif"],
                                                        [UIImage imageNamed:@"2.gif"],
                                                        [UIImage imageNamed:@"3.gif"],
                                                        [UIImage imageNamed:@"1.gif"],
                                                     nil]];
            if([self.bbsForumView respondsToSelector:@selector(unhiddenImage)]){
                [self.bbsForumView performSelector:@selector(unhiddenImage) withObject:nil afterDelay:4.0f];
    
            }
        }
    }

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

    [constraints release];
}

-(void)setMainBoxView{
    
    CGFloat height = 220-21;
    if(ISIPHONE5){
        height = 292-6;
    }
    
    //新建色块
    CGFloat bigViewHeight = height * 0.618f;
    CGFloat smallViewHeight = height - bigViewHeight;
    
    UIImage *paintingImage = [UIImage imageNamed:@"huahua"];
    BrickView *paintingView = [[[BrickView alloc] initWithFrame:self.paintingView.bounds title:NSLS(@"kMetroHomePainting") imageTitle:@"Painting" image:paintingImage] autorelease];
    
    UIImage *learningImage = [UIImage imageNamed:@"xuehuahua"];
    BrickView *learningView = [[[BrickView alloc] initWithFrame:self.learningView.bounds title:NSLS(@"kMetroHomeLearning") imageTitle:@"Learning" image:learningImage] autorelease];
    
    UIImage *forumImage = [UIImage imageNamed:@"luntan"];
    BrickView *forumView = [[[BrickView alloc] initWithFrame:self.forumView.bounds title:NSLS(@"kMetroHomeForum") imageTitle:@"Forum" image:forumImage] autorelease];
    
    UIImage *amazingImage = [UIImage imageNamed:@"jingcaizuopin"];
    BrickView *amazingOpusView = [[[BrickView alloc] initWithFrame:self.amazingOpusView.bounds title:NSLS(@"kMetroHomeGallery") imageTitle:@"Gallery" image:amazingImage] autorelease];
    
    //设置色块背景颜色
    [paintingView setBackgroundColor:[UIColor colorWithRed:0.757f green:0.565f blue:0.965f alpha:1.0f]];
    [learningView setBackgroundColor:[UIColor colorWithRed:0.984f green:0.431f blue:0.588f alpha:1.0f]];
    [forumView setBackgroundColor:[UIColor colorWithRed:0.459f green:0.784f blue:0.965f alpha:1.0f]];
    [amazingOpusView setBackgroundColor:[UIColor colorWithRed:0.553f green:0.612f blue:0.98f alpha:1.0f]];
    
    self.bbsForumView = forumView;
    
//    
//    //设置提醒图标(论坛)
//    CGFloat badgeViewX = 60;
//    CGFloat badgeViewY = 10;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(badgeViewX, badgeViewY, 10, 10)];
//    [imageView setImage:[UIImage imageNamed:@"9.png"]];
//    
//    [forumView addSubview:imageView];
    
    
    [self updateAllBadge];
    
    [self.mainView addSubview:paintingView];
    [self.mainView addSubview:learningView];
    [self.mainView addSubview:forumView];
    [self.mainView addSubview:amazingOpusView];
    
    
    //设置色块autolayout
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
    
    
    
    NSString *paintAndForumViewVertical = [NSString stringWithFormat:@"V:|-7-[paintingView(==%f)]-7-[forumView(==%f)]-7-|",bigViewHeight,smallViewHeight];
    
    NSString *learnAndAmazingViewVertical = [NSString stringWithFormat:@"V:|-7-[learningView(==%f)]-7-[amazingOpusView(==%f)]-7-|",bigViewHeight,smallViewHeight];
    
    [constraints addObject:paintAndForumViewVertical];
    [constraints addObject:learnAndAmazingViewVertical];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:views]];
    }
    
   
    [self setMainViewListening:paintingView
                  learningView:learningView
                     forumView:forumView
               amazingOpusView:amazingOpusView];
    
    [constraints release];
    
    
   
    
}

-(void)setMainBoxView_iPad{
    
    CGFloat height = 595-40;
    
    CGFloat bigViewHeight = height * 0.618f;
    CGFloat smallViewHeight = height - bigViewHeight;
    
    //新建色块中的图片
    UIImage *paintingImage = [UIImage imageNamed:@"huahua"];
    BrickView *paintingView = [[[BrickView alloc] initWithFrame:self.paintingView.bounds title:NSLS(@"kMetroHomePainting") imageTitle:@"Painting" image:paintingImage] autorelease];
    
    UIImage *learningImage = [UIImage imageNamed:@"xuehuahua"];
    BrickView *learningView = [[[BrickView alloc] initWithFrame:self.learningView.bounds title:NSLS(@"kMetroHomeLearning") imageTitle:@"Learning" image:learningImage] autorelease];
    
    UIImage *forumImage = [UIImage imageNamed:@"luntan"];
    BrickView *forumView = [[[BrickView alloc] initWithFrame:self.forumView.bounds title:NSLS(@"kMetroHomeForum") imageTitle:@"Forum" image:forumImage] autorelease];
    
    UIImage *amazingImage = [UIImage imageNamed:@"jingcaizuopin"];
    BrickView *amazingOpusView = [[[BrickView alloc] initWithFrame:self.amazingOpusView.bounds title:NSLS(@"kMetroHomeGallery") imageTitle:@"Gallery" image:amazingImage] autorelease];

    
    self.bbsForumView = forumView;
    
    //建立色块颜色
    [paintingView setBackgroundColor:[UIColor colorWithRed:0.757f green:0.565f blue:0.965f alpha:1.0f]];
    [learningView setBackgroundColor:[UIColor colorWithRed:0.984f green:0.431f blue:0.588f alpha:1.0f]];
    [forumView setBackgroundColor:[UIColor colorWithRed:0.459f green:0.784f blue:0.965f alpha:1.0f]];
    [amazingOpusView setBackgroundColor:[UIColor colorWithRed:0.553f green:0.612f blue:0.98f alpha:1.0f]];
    
    [self updateAllBadge];

    [self.mainView addSubview:paintingView];
    [self.mainView addSubview:learningView];
    [self.mainView addSubview:forumView];
    [self.mainView addSubview:amazingOpusView];
    
    
    //色块在mainView 中的autolayout
    NSDictionary *views = NSDictionaryOfVariableBindings(_mainView,paintingView,learningView, forumView, amazingOpusView);
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [paintingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [learningView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [forumView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [amazingOpusView setTranslatesAutoresizingMaskIntoConstraints:NO];
    //Horizone
    NSString *paintAndLearnViewHorizone = @"H:|-30-[paintingView(==240)]-25-[learningView(==452)]-30-|";
    NSString *forumAndAmazingViewHorizone = @"H:|-30-[forumView(==240)]-25-[amazingOpusView(==452)]-30-|";
    [constraints addObject:paintAndLearnViewHorizone];
    [constraints addObject:forumAndAmazingViewHorizone];
    
    NSString *paintAndForumViewVertical = [NSString stringWithFormat:@"V:|-7-[paintingView(==%f)]-16-[forumView(==%f)]-13-|",bigViewHeight,smallViewHeight];
    
    NSString *learnAndAmazingViewVertical = [NSString stringWithFormat:@"V:|-7-[learningView(==%f)]-16-[amazingOpusView(==%f)]-13-|",bigViewHeight,smallViewHeight];
    
    [constraints addObject:paintAndForumViewVertical];
    [constraints addObject:learnAndAmazingViewVertical];
    
    // Set constraints.
    for (NSString *string in constraints) {
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:string
                                   options:0 metrics:nil
                                   views:views]];
    }
    
    [self setMainViewListening:paintingView
                  learningView:learningView
                     forumView:forumView
               amazingOpusView:amazingOpusView];
    
    [constraints release];

}
#define TRENDS_BUTTON_TITLE_EDGEINSETS   (ISIPAD ? .0 : -50)
#define DOCUMENT_BUTTON_TITLE_EDGEINSETS (ISIPAD ? .0:  .0)
#define MESSAGE_BUTTON_TITLE_EDGEINSET   (ISIPAD ? .0 : .0)
#define MORE_BUTTON_TITLE_EDGEINSETS     (ISIPAD ? .0 : .0)
#define BOTTOM_BUTTON_MARGIN_HEIGHT (ISIPAD ? 50 : 38)
-(void)setBottomViewButton{
    
    //建立tab bar 的按钮
    CGFloat buttonWidth = self.bottomView.bounds.size.width/4;
    CGFloat button_X = buttonWidth;
    NSArray *width = @[@(button_X*0.0f),@(button_X*1.0f),@(button_X*2.0f),@(button_X*3.0f)];
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake([[width objectAtIndex:0] floatValue], 0, buttonWidth, self.bottomView.bounds.size.height)];
    
    UIButton *documentButton = [[UIButton alloc] initWithFrame:CGRectMake([[width objectAtIndex:1] floatValue], 0, buttonWidth, self.bottomView.bounds.size.height)];
    
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake([[width objectAtIndex:2] floatValue], 0, buttonWidth, self.bottomView.bounds.size.height)];
    
     UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake([[width objectAtIndex:3] floatValue], 0, buttonWidth, self.bottomView.bounds.size.height)];
    
    //设置按钮的icon
    [indexButton setImage:[UIImage imageNamed:@"dongtai"] forState:UIControlStateNormal];
    [documentButton setImage:[UIImage imageNamed:@"caogao"] forState:UIControlStateNormal];
    [messageButton setImage:[UIImage imageNamed:@"xiaoxi"] forState:UIControlStateNormal];
    [moreButton setImage:[UIImage imageNamed:@"gengduo"] forState:UIControlStateNormal];
    
    //设置按钮title
    const CGFloat cutSize = (ISIPAD ? 32:20);
    UILabel *indexButtonTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, self.bottomView.bounds.size.height-cutSize, buttonWidth, 20)] autorelease];
    [self setBottomButtonTitleStyle:indexButtonTitle text:NSLS(@"kMetroIndexButton")];
    [indexButton addSubview:indexButtonTitle];
     self.indexBadge.frame = CGRectMake([[width objectAtIndex:0] floatValue], 0, (ISIPAD?30:20), (ISIPAD?30:20));
    
    UILabel *documentButtonTitle = [[[UILabel alloc] initWithFrame:CGRectMake([[width objectAtIndex:0] floatValue], self.bottomView.bounds.size.height-cutSize, buttonWidth, 20)] autorelease];
    [self setBottomButtonTitleStyle:documentButtonTitle text:NSLS(@"kMetroDocumentButton")];
    [documentButton addSubview:documentButtonTitle];
    self.indexBadge.frame = CGRectMake([[width objectAtIndex:1] floatValue], 0, (ISIPAD?30:20), (ISIPAD?30:20));
    
    UILabel *messageButtonTitle = [[[UILabel alloc] initWithFrame:CGRectMake([[width objectAtIndex:0] floatValue], self.bottomView.bounds.size.height-cutSize, buttonWidth, 20)] autorelease];
    [self setBottomButtonTitleStyle:messageButtonTitle text:NSLS(@"kMetroMessageButton")];
    [messageButton addSubview:messageButtonTitle];
     self.indexBadge.frame = CGRectMake([[width objectAtIndex:2] floatValue], 0, (ISIPAD?30:20), (ISIPAD?30:20));
    
    UILabel *moreButtonTitle = [[[UILabel alloc] initWithFrame:CGRectMake([[width objectAtIndex:0] floatValue], self.bottomView.bounds.size.height-cutSize, buttonWidth, 20)] autorelease];
    [self setBottomButtonTitleStyle:moreButtonTitle text:NSLS(@"kMetroMoreButton")];
    [moreButton addSubview:moreButtonTitle];
     self.indexBadge.frame = CGRectMake([[width objectAtIndex:3] floatValue], 0, (ISIPAD?30:20), (ISIPAD?30:20));
    
    //设置按钮图片位置
    //负数上升，正数下降
    CGFloat imageTopEdge = (ISIPAD ? -30:-10);
    indexButton.imageEdgeInsets = UIEdgeInsetsMake(imageTopEdge,0,0,0);
    documentButton.imageEdgeInsets = UIEdgeInsetsMake(imageTopEdge,0,0,0);
    messageButton.imageEdgeInsets = UIEdgeInsetsMake(imageTopEdge,0,0,0);
    moreButton.imageEdgeInsets = UIEdgeInsetsMake(imageTopEdge,0,0,0);
    
    //背景颜色
    [documentButton setBackgroundColor:[UIColor clearColor]];
    [messageButton setBackgroundColor:[UIColor clearColor]];
    [moreButton setBackgroundColor:[UIColor clearColor]];
    [indexButton setBackgroundColor:[UIColor clearColor]];
    
    
    
    [self.bottomView addSubview:indexButton];
    [self.bottomView addSubview:documentButton];
    [self.bottomView addSubview:messageButton];
    [self.bottomView addSubview:moreButton];
    
    //监听按钮
    [self setBottomButtonListening:indexButton draft:documentButton chat:messageButton more:moreButton];
    
}
//设置button 的样式
-(void)setBottomButtonTitleStyle:(UILabel *)label text:(NSString*)text{
    
    UIFont *font = nil;
    if([LocaleUtils isChina]||[LocaleUtils isChinese]){
        font = AD_FONT(13, 10);
        
    }else{
        font = AD_BOLD_FONT(11,10);
    }
    [label setText:text];
    [label setFont:font];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor colorWithRed:0.467 green:0.467 blue:0.467 alpha:1.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    
}


#pragma mark - Listen
-(void)setListenInView:(UIView*)view selector:(SEL)selector{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [view addGestureRecognizer:singleTap];
}
-(void)setListenInButton:(UIButton*)button selector:(SEL)selector{
    [button addTarget:self action:@selector(selector) forControlEvents:nil];
}
//监听色块
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
//监听按钮
-(void)setBottomButtonListening:(UIButton*)indexButton draft:(UIButton*)draft chat:(UIButton*)chat more:(UIButton*)more{
    
    [self setListenInView:indexButton selector:@selector(goToIndexController:)];
    [self setListenInView:draft selector:@selector(goToDocumentController:)];
    [self setListenInView:chat selector:@selector(goToMessageController:)];
    [self setListenInView:more selector:@selector(goToMoreController:)];
    
    
}




@end
