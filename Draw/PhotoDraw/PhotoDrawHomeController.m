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

@interface PhotoDrawHomeController ()
@property (retain, nonatomic) UIView  *adView;
@property (retain, nonatomic) UIPopoverController *photoPopoverController;

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
                                                   iPadFrame:CGRectMake(0, 914, 320, 50)
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
    NSString *subject = [NSString stringWithFormat:@"%@ %@", [UIUtils getAppName], NSLS(@"kFeedback")];
    [self sendEmailTo:list ccRecipients:nil bccRecipients:nil subject:subject body:@"" isHTML:NO delegate:nil];
}

- (void)selectPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.allowsEditing = YES;
        picker.delegate = self;
        
        if ([DeviceDetection isIPAD]){
            UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.photoPopoverController = controller;
            [controller release];
            CGRect popoverRect = CGRectMake((768-400)/2, -140, 400, 400);
            [_photoPopoverController presentPopoverFromRect:popoverRect
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
        } else {
            [self presentModalViewController:picker animated:YES];
        }
        [picker release];
    }
}

- (void)useSelectedBgImage:(UIImage *)image
{
    [OfflineDrawViewController startDraw:[Word wordWithText:NSLS(@"kLearnDrawWord") level:1] fromController:self startController:self targetUid:nil photo:image];
}

#pragma mark -- UIImagePickerControllerDelegate

#define MAX_LEN_CUSTOM 1024.0
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *infoKey = (picker.sourceType == UIImagePickerControllerSourceTypeCamera ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage);
    UIImage *image = [info objectForKey:infoKey];
    if (image != nil){
        image = [image fixOrientation];
        
        PPDebug(@"image width:%f height:%f", image.size.width, image.size.height);
        
        CGFloat maxLen = (image.size.width > image.size.height ? image.size.width : image.size.height);
        if (maxLen > MAX_LEN_CUSTOM) {
            CGFloat mul = MAX_LEN_CUSTOM / maxLen;
            CGSize customSize;
            if (maxLen == image.size.width) {
                customSize = CGSizeMake(MAX_LEN_CUSTOM, image.size.height * mul);
            }else {
                customSize = CGSizeMake(image.size.width * mul, MAX_LEN_CUSTOM);
            }
            image = [UIImage createRoundedRectImage:image size:customSize];
        }
        
        [self useSelectedBgImage:image];
    }
    [self dismissModalViewControllerAnimated:YES];
    
    if (_photoPopoverController != nil) {
        [_photoPopoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_photoPopoverController != nil) {
        [_photoPopoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
}

@end
