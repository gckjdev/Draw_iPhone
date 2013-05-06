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
#import "MKBlockActionSheet.h"
#import "UIImage+fixOrientation.h"
#import "UIImageExt.h"
#import "PhotoDrawSheet.h"

@interface PhotoDrawHomeController ()
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) UIPopoverController *photoPopoverController;
@property (retain, nonatomic) PhotoDrawSheet *photoDrawSheet;

@end

@implementation PhotoDrawHomeController

- (void)dealloc {
    [_adView release];
    [_photoPopoverController release];
    [_bgImageView release];
    [_paperImageView release];
    [_topImageView release];
    [_clipImageView release];
    [_drawButton release];
    [_shopButton release];
    [_opusButton release];
    [_feedbackButton release];
    [_photoDrawSheet release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.drawButton setTitle:NSLS(@"kPhotoDrawDraw") forState:UIControlStateNormal];
    [self.shopButton setTitle:NSLS(@"kPhotoDrawShop") forState:UIControlStateNormal];
    [self.opusButton setTitle:NSLS(@"kPhotoDrawOpus") forState:UIControlStateNormal];
    [self.feedbackButton setTitle:NSLS(@"kPhotoDrawFeedback") forState:UIControlStateNormal];
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 70, 320, 50)
                                                   iPadFrame:CGRectMake((768-320)/2, 914, 320, 50)
                                                     useLmAd:NO];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    [self setBgImageView:nil];
    [self setPaperImageView:nil];
    [self setTopImageView:nil];
    [self setClipImageView:nil];
    [self setDrawButton:nil];
    [self setShopButton:nil];
    [self setOpusButton:nil];
    [self setFeedbackButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)clickDrawButton:(id)sender {
    self.photoDrawSheet =[PhotoDrawSheet createSheetWithSuperController:self];
    [_photoDrawSheet showSheet];
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
