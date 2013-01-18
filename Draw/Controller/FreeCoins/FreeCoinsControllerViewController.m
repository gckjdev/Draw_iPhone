//
//  FreeCoinsControllerViewController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-10.
//
//

#import "FreeCoinsControllerViewController.h"
#import "shengmengsdk.h"
#import "LmWallService.h"
#import "BBSBoardController.h"
#import "AnalyticsManager.h"
#import "UMGridViewController.h"
#import "AdService.h"
#import "AnalyticsManager.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "ItemType.h"
#import "ConfigManager.h"
#import "TimeUtils.h"

//#define TAPJOY_APP_ID @"54f9ea4b-beee-4fac-84ee-a34522e67b34"
//#define TAPJOY_APP_SECRET_KEY @"huXKYqkwpxlKbgrIxOIT"
//#define TAPJOY_APP_ID_TEST @"93e78102-cbd7-4ebf-85cc-315ba83ef2d5"
//#define TAPJOY_APP_SECRET_KEY_TEST @"JWxgS26URM0XotaghqGn"

#define KEY_ENTER_FREE_COINS_CONTROLLER_TIMES @"KEY_ENTER_FREE_COINS_CONTROLLER_TIMES"
#define KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE @"KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE"

@interface FreeCoinsControllerViewController ()

@end

@implementation FreeCoinsControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (int)getFreeCoinsAwardTimesForToday
{
    int times = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_ENTER_FREE_COINS_CONTROLLER_TIMES];
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE];
    
    if (isToday(lastDate)) {
        return times;
    }else{
        return 0;
    }
}

- (void)addFreeCoinsAwardTimesForToday
{
    int times = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_ENTER_FREE_COINS_CONTROLLER_TIMES];
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE];
    
    if (isToday(lastDate)) {
        times ++;
    }else{
        times = 1;
        lastDate = [NSDate date];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:times forKey:KEY_ENTER_FREE_COINS_CONTROLLER_TIMES];
    [[NSUserDefaults standardUserDefaults] setObject:lastDate forKey:KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.cannotGetFreeCoinsLabel.text = NSLS(@"kMoneyTreeAwardEnd");
    
    if (![ConfigManager wallEnabled]) {
        self.lmWallBtnHolderView.hidden = YES;
        self.helpBtnHolderView.frame = self.lmWallBtnHolderView.frame; 
    }
    
    int remainTimes = [self remainTimes];
    if (remainTimes <= 0) {
        [self enableFreeCoinsAward:NO];
    }
    else
    {
        [self enableFreeCoinsAward:YES];
        
        self.noteLabel.text = NSLS(@"kWaitForMoneyTreeGrowUp");
        [self updateRemainTimes:remainTimes];
        
        
        self.moneyTree.growthTime = [ConfigManager getFreeCoinsMoneyTreeGrowthTime];
        self.moneyTree.gainTime = [ConfigManager getFreeCoinsMoneyTreeGainTime];
        self.moneyTree.coinValue = [ConfigManager getFreeCoinsAward];
        self.moneyTree.delegate = self;

        [self.moneyTree startGrow];
        
        int sec = [self.moneyTree totalTime];
        
        self.timeLabel.text = [NSString stringWithFormat:NSLS(@"kRemainTime"),sec/60, sec%60];
    }
    
    // shengmeng sdk
    self.timer = [NSTimer scheduledTimerWithTimeInterval:80 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
    [shengmengsdk playad:[GameApp shengmengAppId]];
    
    // NOTE: This must be replaced by your App ID. It is Retrieved from the Tapjoy website, in your account.
    
    CGSize adSize = CGSizeMake(320, 50);
    
    [[AdService defaultService] createAdInView:self.view frame:CGRectMake((self.view.frame.size.width - adSize.width) / 2, self.view.frame.size.height-adSize.height, adSize.width, adSize.height) iPadFrame:CGRectMake((self.view.frame.size.width - adSize.width) / 2, self.view.frame.size.height-adSize.height - 20, adSize.width, adSize.height)];
}

-(void)enableFreeCoinsAward:(BOOL)enabled
{
    self.moneyTree.hidden = !enabled;
    self.noteLabel.hidden = !enabled;
    self.remainTimesLabel.hidden = !enabled;
    self.timeLabel.hidden = !enabled;
    self.noteBgImageView.hidden = !enabled;
    self.cannotGetFreeCoinsImageView.hidden = enabled;
    self.cannotGetFreeCoinsLabel.hidden = enabled;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _moneyTree.delegate = nil;
    [_titleTlabel release];
    [_moneyTreeHolderView release];
    [_lmWallBtnHolderView release];
    [_helpBtnHolderView release];
    [_noteLabel release];
    [_remainTimesLabel release];
    [_cannotGetFreeCoinsImageView release];
    [_cannotGetFreeCoinsLabel release];
    [_timeLabel release];
    [_moneyTree release];
    [_noteBgImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleTlabel:nil];
    [self setMoneyTreeHolderView:nil];
    [self setLmWallBtnHolderView:nil];
    [self setHelpBtnHolderView:nil];
    [self setNoteLabel:nil];
    [self setRemainTimesLabel:nil];
    [self setCannotGetFreeCoinsImageView:nil];
    [self setCannotGetFreeCoinsLabel:nil];
    [self setTimeLabel:nil];
    [self setMoneyTree:nil];
    [self setNoteBgImageView:nil];
    [super viewDidUnload];
}

- (IBAction)clickWatchVideoButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportFreeCoins:FREE_COIN_TYPE_VIDEO];
    [TapjoyConnect showOffersWithViewController:self];
}

- (IBAction)clickDownloadAppsButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportFreeCoins:FREE_COIN_TYPE_JIFENQIANG];

    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];
}

- (IBAction)clickHelpButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_BBS];
    
    BBSBoardController *bbs = [[[BBSBoardController alloc] init] autorelease];
    [self.navigationController pushViewController:bbs animated:YES];
}

- (void)timeout:(id)sender {
    [shengmengsdk playad:[GameApp shengmengAppId]];
}

- (IBAction)clickBackButton:(id)sender {
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (int)remainTimes
{
    return [ConfigManager getMaxCountForFetchFreeCoinsOneDay] - [self getFreeCoinsAwardTimesForToday];
}

- (void)updateRemainTimes:(int)times
{
    self.remainTimesLabel.text = [NSString stringWithFormat:NSLS(@"kRemainTimes"), times];
}

// 点击树时，如果树还没有金币的时候回调
- (void)moneyTreeNoCoin:(MoneyTree*)tree
{
    PPDebug(@"moneyTreeNoCoin");
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kMoneyTreeNotCoinYet") delayTime:1.5 isHappy:NO];
}

// 点击树时，如果树上有金币的时候回调
- (void)getMoney:(int)money fromTree:(MoneyTree*)tree
{
    [[AnalyticsManager sharedAnalyticsManager] reportFreeCoins:FREE_COIN_TYPE_MONEYTREE];
    
    [self addFreeCoinsAwardTimesForToday];
    
    int tipsAward = [ConfigManager getFreeTipsAward];
    int flowersAward = [ConfigManager getFreeFlowersAward];
    
    [[AccountService defaultService] chargeAccount:money source:MoneyTreeAward];
    [[AccountService defaultService] buyItem:ItemTypeTips itemCount:tipsAward itemCoins:0];
    [[AccountService defaultService] buyItem:ItemTypeFlower itemCount:flowersAward itemCoins:0];
    
    
    NSString *moneyStr = (money <= 0) ? @"" : [NSString stringWithFormat:NSLS(@"kGainFreeCoinsNote"), money];
    NSString *flowersStr = (flowersAward == 0) ? @"" : [[NSString stringWithFormat:NSLS(@"+%d"), flowersAward] stringByAppendingString:NSLS(@"kFlower")];
    NSString *TipsStr = (tipsAward == 0) ? @"" : [[NSString stringWithFormat:NSLS(@"+%d"), tipsAward] stringByAppendingString:NSLS(@"kTips")];
    
    int remainTimes = [self remainTimes];
    NSString *remainTimesStr = [NSString stringWithFormat:NSLS(@"kRemainTimes"), remainTimes];
    
    NSString *note = [[[moneyStr stringByAppendingString:flowersStr] stringByAppendingString:TipsStr] stringByAppendingString:remainTimesStr];
    
    if (note != nil && ![note isEqualToString:@""]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:note delayTime:3 isHappy:YES];
    }
    
    if ([self remainTimes] <= 0) {
        [self enableFreeCoinsAward:NO];
    }else
    {
        [self updateRemainTimes:remainTimes];
        self.noteLabel.text = NSLS(@"kWaitForMoneyTreeAward");
    }
}

// 树长大的回调
- (void)treeDidMature:(MoneyTree*)tree
{
    self.noteLabel.text = NSLS(@"kWaitForMoneyTreeAward");
}

// 长满金币时回调
- (void)treeFullCoins:(MoneyTree*)tree
{
    self.noteLabel.text = NSLS(@"kClickMoneyTreeToGetAward");
    self.timeLabel.text = [NSString stringWithFormat:NSLS(@"kRemainTime"),0, 0];
}

// 倒计时回调
- (void)treeUpdateRemainSeconds:(int)seconds
                     toFullCoin:(MoneyTree*)tree
{
    self.timeLabel.text = [NSString stringWithFormat:NSLS(@"kRemainTime"),seconds/60, seconds%60];
}


@end
