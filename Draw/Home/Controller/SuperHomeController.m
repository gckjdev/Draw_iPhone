//
//  SuperHomeController.m
//  Draw
//
//  Created by qqn_pipi on 12-10-6.
//
//

#import "SuperHomeController.h"
#import "HomeMenuView.h"
#import "CoinShopController.h"
#import "StatisticManager.h"
#import "UserManager.h"
#import "RegisterUserController.h"
#import "UserSettingController.h"

@interface SuperHomeController ()
{
    
}

@end


#define MAIN_MENU_ORIGIN_Y ISIPAD ? 365 : 170
#define BOTTOM_MENU_ORIGIN_Y ISIPAD ? (1004-97) : 422

@implementation SuperHomeController

-(void)dealloc
{
    PPRelease(_homeBottomMenuPanel);
    PPRelease(_homeHeaderPanel);
    PPRelease(_homeMainMenuPanel);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateView:(UIView *)view originY:(CGFloat)y
{
    CGRect frame = view.frame;
    CGPoint origin = frame.origin;
    origin.y = y;
    frame.origin = origin;
    view.frame = frame;
}

- (void)addHeaderView
{
    self.homeHeaderPanel = [HomeHeaderPanel createView:self];
    [self.view addSubview:self.homeHeaderPanel];
    [self updateView:self.homeHeaderPanel originY:0];
}



- (void)addMainMenuView
{
    self.homeMainMenuPanel = [HomeMainMenuPanel createView:self];
    [self.view addSubview:self.homeMainMenuPanel];
//    self.mainMenuPanel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    //TODO update frame
    [self updateView:self.homeMainMenuPanel originY:MAIN_MENU_ORIGIN_Y];
}

- (void)addBottomMenuView
{
    self.homeBottomMenuPanel = [HomeBottomMenuPanel createView:self];
    [self.view addSubview:self.homeBottomMenuPanel];
    [self updateView:self.homeBottomMenuPanel originY:BOTTOM_MENU_ORIGIN_Y];
}

- (void)viewDidLoad
{
    PPDebug(@"SuperHomeController view did load");
    [super viewDidLoad];
    if (!ISIPAD) {
        self.view.frame = CGRectMake(0, 0, 320, 460);
    }
    [self addMainMenuView];
    [self addHeaderView];
    [self addBottomMenuView];
    
    if (!ISIPAD) {
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(handleStaticTimer:) userInfo:nil repeats:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeMainMenuPanel animatePageButtons];
    [self.homeHeaderPanel updateView];
    [self updateAllBadge];
}

- (void)viewDidUnload
{
    self.homeHeaderPanel = nil;
    self.homeMainMenuPanel = nil;
    self.homeBottomMenuPanel = nil;
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get && update statistic
- (void)handleStaticTimer:(NSTimer *)theTimer
{
    PPDebug(@"<handleStaticTimer>: get static");
    [[UserService defaultService] getStatistic:self];
}

- (void)updateAllBadge
{
    StatisticManager *manager = [StatisticManager defaultManager];
    
    [self.homeBottomMenuPanel updateMenu:HomeMenuTypeDrawMessage badge:manager.messageCount];
    [self.homeBottomMenuPanel updateMenu:HomeMenuTypeDrawFriend badge:manager.fanCount];
    
    long timelineCount = manager.feedCount + manager.commentCount + manager.drawToMeCount;
    [self.homeMainMenuPanel updateMenu:HomeMenuTypeDrawTimeline badge:timelineCount];
    
}

- (void)didGetStatistic:(int)resultCode
              feedCount:(long)feedCount
           messageCount:(long)messageCount
               fanCount:(long)fanCount
              roomCount:(long)roomCount
           commentCount:(long)commentCount
          drawToMeCount:(long)drawToMeCount
{
    if (resultCode == 0) {
        PPDebug(@"<didGetStatistic>:feedCount = %ld, messageCount = %ld, fanCount = %ld", feedCount,messageCount,fanCount);
        
        //store the counts.
        StatisticManager *manager = [StatisticManager defaultManager];
        [manager setFeedCount:feedCount];
        [manager setMessageCount:messageCount];
        [manager setFanCount:fanCount];
        [manager setRoomCount:roomCount];
        [manager setCommentCount:commentCount];
        [manager setDrawToMeCount:drawToMeCount];
        
        [self updateAllBadge];
    }
}

#pragma mark - Panels Delegate

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickChargeButton:(UIButton *)button
{
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }

    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickAvatarButton:(UIButton *)button
{
    if ([self isRegistered] == NO) {
        [self toRegister];
        return;
    }

    UserSettingController *us = [[UserSettingController alloc] init];
    [self.navigationController pushViewController:us animated:YES];
    [us release];
}

#pragma mark register

- (BOOL)isRegistered
{
    return [[UserManager defaultManager] hasUser];
}

- (void)toRegister
{
    RegisterUserController *ruc = [[RegisterUserController alloc] init];
    [self.navigationController pushViewController:ruc animated:YES];
    [ruc release];
}

@end
