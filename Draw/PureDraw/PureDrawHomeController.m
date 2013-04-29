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
    [_drawButton release];
    [_shopButton release];
    [_opusButton release];
    [_feedbackButton release];
    [_titleLabel release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    [self setDrawButton:nil];
    [self setShopButton:nil];
    [self setOpusButton:nil];
    [self setFeedbackButton:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:[UIUtils getAppName]];
    [self.drawButton setTitle:NSLS(@"kPureDrawDraw") forState:UIControlStateNormal];
    [self.shopButton setTitle:NSLS(@"kPureDrawShop") forState:UIControlStateNormal];
    [self.opusButton setTitle:NSLS(@"kPureDrawOpus") forState:UIControlStateNormal];
    [self.feedbackButton setTitle:NSLS(@"kPureDrawFeedback") forState:UIControlStateNormal];
    
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, 320, 50)
                                                   iPadFrame:CGRectMake((768-320)/2, 914, 320, 50)
                                                     useLmAd:NO];
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
    NSString *subject = [NSString stringWithFormat:@"%@ %@", [UIUtils getAppName], NSLS(@"kFeedback")];
    [self sendEmailTo:list ccRecipients:nil bccRecipients:nil subject:subject body:@"" isHTML:NO delegate:nil];
}

@end
