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

@interface PhotoDrawHomeController ()
@property (retain, nonatomic) UIView  *adView;
@end

@implementation PhotoDrawHomeController

- (void)dealloc {
    [_adView release];
    [_bgImageView release];
    [_paperImageView release];
    [_topImageView release];
    [_clipImageView release];
    [_drawButton release];
    [_shopButton release];
    [_opusButton release];
    [_feedbackButton release];
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
                                                   iPadFrame:CGRectMake(224, 954, 320, 50)
                                                     useLmAd:YES];
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
    MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc] initWithTitle:nil
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLS(@"kCancel")
                                                   destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kTakePhoto"), NSLS(@"kBlank"), nil];
    __block typeof (self)bself = self;
    [sheet setActionBlock:^(NSInteger buttonIndex){
        switch (buttonIndex) {
            case 0:
                [bself selectPhoto];
                break;
            case 1:
                [bself takePhoto];
                break;
            case 2:
                [bself useSelectedBgImage:nil];
                break;
            default:
                break;
        }
    }];
    [sheet showInView:self.view];
    [sheet release];
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


- (void)useSelectedBgImage:(UIImage *)image
{
    [OfflineDrawViewController startDraw:[Word wordWithText:NSLS(@"kLearnDrawWord") level:1] fromController:self startController:self targetUid:nil photo:image];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (image != nil){
        [self useSelectedBgImage:image];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image != nil){
        [self useSelectedBgImage:image];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
