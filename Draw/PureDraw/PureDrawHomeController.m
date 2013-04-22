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

@interface PureDrawHomeController ()

@end

@implementation PureDrawHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
