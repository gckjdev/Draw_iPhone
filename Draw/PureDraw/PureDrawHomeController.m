//
//  PureDrawHomeController.m
//  Draw
//
//  Created by haodong on 13-4-19.
//
//

#import "PureDrawHomeController.h"
#import "AnalyticsManager.h"
#import "OfflineDrawViewController.h"
#import "ShareController.h"
#import "StoreController.h"
#import "AdService.h"

@interface PureDrawHomeController ()
@property (retain, nonatomic) UIView  *adView;
@end

@implementation PureDrawHomeController

- (void)dealloc
{
    [_adView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PPDebug(@"view height:%f", self.view.frame.size.height);
    
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, 320, 50)
                                                   iPadFrame:CGRectMake(224, 954, 320, 50)
                                                     useLmAd:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)clickDrawButton:(id)sender {
    [OfflineDrawViewController startDraw:[Word wordWithText:NSLS(@"kLearnDrawWord") level:1] fromController:self startController:self targetUid:nil];
}

- (IBAction)clickShopButton:(id)sender {
    StoreController *controller = [[[StoreController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clickOpusButton:(id)sender {
    ShareController* share = [[ShareController alloc] init];
    [share setDefaultTabIndex:2];
    [self.navigationController pushViewController:share animated:YES];
    [share release];
}

- (IBAction)clickFeedbackButton:(id)sender {
    NSArray *list = [ConfigManager getLearnDrawFeedbackEmailList];
    if ([list count] == 0) {
        return;
    }
    [self sendEmailTo:list ccRecipients:nil bccRecipients:nil subject:NSLS(@"kFeedback") body:@"" isHTML:NO delegate:nil];
}

@end
