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

#define SHENGMENG_APP_ID @"90386ecaab5c85559c569ab7c79a61e2"
//#define TAPJOY_APP_ID @"54f9ea4b-beee-4fac-84ee-a34522e67b34"
//#define TAPJOY_APP_SECRET_KEY @"huXKYqkwpxlKbgrIxOIT"
//#define TAPJOY_APP_ID_TEST @"93e78102-cbd7-4ebf-85cc-315ba83ef2d5"
//#define TAPJOY_APP_SECRET_KEY_TEST @"JWxgS26URM0XotaghqGn"

#define KEY_ENTER_FREE_COINS_CONTROLLER_TIMES "KEY_ENTER_FREE_COINS_CONTROLLER_TIMES"
#define KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE "KEY_LAST_ENTER_FREE_COINS_CONTROLLER_DATE"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if (![ConfigManager wallEnabled]) {
        self.lmWallBtnHolderView.hidden = YES;
        self.helpBtnHolderView.frame = self.lmWallBtnHolderView.frame;
    }
    
    if (times > [ConfigManager getMaxCountForFetchFreeCoinsOneDay]) {
        self.noteLabel.hidden = YES;
    
    }else{
        self.noteLabel.text = NSLS(@"kWaitForMoneyTreeGrowUp");
        
        self.moneyTreeView = [MoneyTreeView createMoneyTreeView];
        self.moneyTreeView.center = self.moneyTreePlaceHolder.center;
        self.moneyTreeView.growthTime = 30;
        self.moneyTreeView.gainTime = 30;
        self.moneyTreeView.coinValue = [ConfigManager getFreeCoinsAward];
        
        self.moneyTreeView.delegate = self;
        [self.moneyTreeHolderView addSubview:_moneyTreeView];
        self.moneyTreeView.isAlwaysShowMessage = YES;
        [self.moneyTreeView startGrowing];
    }
    
    // shengmeng sdk
    self.timer = [NSTimer scheduledTimerWithTimeInterval:80 target:self selector:@selector(timeout:) userInfo:nil repeats:YES];
    [shengmengsdk playad:SHENGMENG_APP_ID];
    
    // NOTE: This must be replaced by your App ID. It is Retrieved from the Tapjoy website, in your account.
    
    [[AdService defaultService] createAdInView:self.view frame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 50) iPadFrame:CGRectMake(0, self.view.frame.size.height-100, self.view.frame.size.width, 100)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_titleTlabel release];
    [_moneyTreePlaceHolder release];
    [_moneyTreeView release];
    [_moneyTreeHolderView release];
    [_lmWallBtnHolderView release];
    [_helpBtnHolderView release];
    [_noteLabel release];
    [_remainTimesLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleTlabel:nil];
    [self setMoneyTreePlaceHolder:nil];
    [self setMoneyTreeHolderView:nil];
    [self setLmWallBtnHolderView:nil];
    [self setHelpBtnHolderView:nil];
    [self setNoteLabel:nil];
    [self setRemainTimesLabel:nil];
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
//    UMGridViewController *controller = [[UMGridViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
}

- (IBAction)clickHelpButton:(id)sender {
    [[AnalyticsManager sharedAnalyticsManager] reportClickHomeMenu:HOME_ACTION_BBS];
    
    BBSBoardController *bbs = [[[BBSBoardController alloc] init] autorelease];
    [self.navigationController pushViewController:bbs animated:YES];
}

- (void)timeout:(id)sender {
    [shengmengsdk playad:SHENGMENG_APP_ID];
}

- (IBAction)clickBackButton:(id)sender {
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didGainMoney:(int)money fromTree:(MoneyTreeView *)treeView
{
    [[AnalyticsManager sharedAnalyticsManager] reportFreeCoins:FREE_COIN_TYPE_MONEYTREE];

    int tipsAward = [ConfigManager getFreeTipsAward];
    int flowersAward = [ConfigManager getFreeFlowersAward];

    [[AccountService defaultService] chargeAccount:money source:MoneyTreeAward];
    [[AccountService defaultService] buyItem:ItemTypeTips itemCount:tipsAward itemCoins:0];
    [[AccountService defaultService] buyItem:ItemTypeFlower itemCount:flowersAward itemCoins:0];
   
    
    NSString *moneyStr = (money <= 0) ? @"" : [NSString stringWithFormat:NSLS(@"kGainFreeCoinsNote"), money];
    NSString *flowersStr = (flowersAward == 0) ? @"" : [[NSString stringWithFormat:NSLS(@"+%d")] stringByAppendingString:NSLS(@"kFlower")];
    NSString *TipsStr = (tipsAward == 0) ? @"" : [[NSString stringWithFormat:NSLS(@"+%d")] stringByAppendingString:NSLS(@"kTips")];
    
    NSString *note = [[moneyStr stringByAppendingString:flowersStr] stringByAppendingString:TipsStr];

    if (note != nil && ![note isEqualToString:@""]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:note delayTime:1.5 isHappy:YES];
    }
}

- (void)moneyTreeDidMature:(MoneyTreeView*)treeView;
{
    self.noteLabel.text = NSLS(@"kMoneyTreeGrowUp");
    [self.noteLabel performSelector:@selector(setText:) withObject:NSLS(@"kWaitForMoneyAndFlowsAndTips") afterDelay:1];
}


@end
