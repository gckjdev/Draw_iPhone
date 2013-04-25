//
//  PhotoDrawHomeController.m
//  Draw
//
//  Created by haodong on 13-4-22.
//
//

#import "PhotoDrawHomeController.h"
#import "AnalyticsManager.h"
#import "OfflineDrawViewController.h"
#import "ShareController.h"
#import "StoreController.h"
#import "AdService.h"

@interface PhotoDrawHomeController ()

@end

@implementation PhotoDrawHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)clickDrawButton:(id)sender {
    [self takePhoto];
    //[OfflineDrawViewController startDraw:[Word wordWithText:NSLS(@"kLearnDrawWord") level:1] fromController:self startController:self targetUid:nil];
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
