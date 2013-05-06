//
//  LearnDrawPreViewController.m
//  Draw
//
//  Created by gamy on 13-4-15.
//
//

#import "LearnDrawPreViewController.h"
#import "UIImageView+WebCache.h"
#import "ReplayView.h"
#import "LearnDrawService.h"
#import "FeedService.h"
#import "Draw.h"
#import "ConfigManager.h"
#import "BalanceNotEnoughAlertView.h"
#import "ShareAction.h"
#import "CommonMessageCenter.h"
#import "LearnDrawManager.h"

@interface LearnDrawPreViewController ()

@property (retain, nonatomic) UIImage* placeHolderImage;
@property (retain, nonatomic) DrawFeed* feed;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *contentImageView;
@property (retain, nonatomic) IBOutlet UIButton *previewButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIView *priceHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *ingotImageView;

- (IBAction)clickPreview:(id)sender;
- (IBAction)clickBuyButton:(id)sender;
- (IBAction)clickClose:(id)sender;

@end

@implementation LearnDrawPreViewController


+ (LearnDrawPreViewController *)enterLearnDrawPreviewControllerFrom:(UIViewController *)fromController
                                                             drawFeed:(DrawFeed *)drawFeed
                                                     placeHolderImage:(UIImage *)image
{
    LearnDrawPreViewController *ldp = [[[LearnDrawPreViewController alloc] init] autorelease];
    [ldp setFeed:drawFeed];
    [ldp setPlaceHolderImage:image];
    [fromController.navigationController pushViewController:ldp animated:YES];
    return ldp;
}



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
    
    NSURL *url = ISIPAD ? self.feed.largeImageURL : self.feed.thumbURL;
    
    [self.contentImageView setImageWithURL:url
                          placeholderImage:self.placeHolderImage];
    [self.titleLabel setText:NSLS(@"kLearnDrawPreviewTitle")];
    
    [self.priceHolderView updateOriginX:self.contentImageView.frame.origin.x];
    [self.priceHolderView updateOriginY:self.contentImageView.frame.origin.y + self.contentImageView.frame.size.height - self.priceHolderView.frame.size.height];
    [self.priceHolderView updateWidth:self.contentImageView.frame.size.width];    
    [self.ingotImageView updateOriginX: 0.5 * self.priceHolderView.frame.size.width - self.ingotImageView.frame.size.width];
    [self.priceLabel updateOriginX:self.ingotImageView.frame.origin.x + 1.5 * self.ingotImageView.frame.size.width];
    self.priceLabel.text =  [NSString stringWithFormat:@"%d", self.feed.learnDraw.price];
    
    NSString *leftTitle = nil;
    NSString *rightTitle = nil;
    SEL leftSelector;
    SEL rightSelector;
    if (isLearnDrawApp()) {
        leftTitle = NSLS(@"kLearnDrawPreview");
        rightTitle = NSLS(@"kLearnDrawBuy");
        leftSelector = @selector(clickPreview:);
        rightSelector = @selector(clickBuyButton:);
    } else if (isDreamAvatarApp() || isDreamAvatarFreeApp()){
        leftTitle = NSLS(@"kDreamAvatarSaveToAlbum");
        rightTitle = NSLS(@"kDreamAvatarSaveToContact");
        leftSelector = @selector(clickSaveToAlbum:);
        rightSelector = @selector(clickSaveToAvatar:);
    }
    
    [self.previewButton setTitle:leftTitle forState:UIControlStateNormal];
    [self.buyButton setTitle:rightTitle forState:UIControlStateNormal];
    
    [self.previewButton addTarget:self action:leftSelector forControlEvents:UIControlEventTouchUpInside];
    [self.buyButton addTarget:self action:rightSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_placeHolderImage);
    PPRelease(_titleLabel);
    PPRelease(_contentImageView);
    PPRelease(_previewButton);
    PPRelease(_buyButton);
    _feed.pbDrawData = nil;
    _feed.drawData = nil;
    PPRelease(_feed);
    [_priceLabel release];
    [_priceHolderView release];
    [_ingotImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setContentImageView:nil];
    [self setPreviewButton:nil];
    [self setBuyButton:nil];
    [self setPriceLabel:nil];
    [self setPriceHolderView:nil];
    [self setIngotImageView:nil];
    [super viewDidUnload];
}

- (IBAction)clickClose:(id)sender {
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#define PREVIEW_DIV 5

- (NSInteger)previewActionCountOfFeed:(DrawFeed *)feed
{
    NSMutableArray *list = feed.drawData.drawActionList;
    if ([list count] != 0) {
        NSInteger count = [ConfigManager getPreviewActionCount];
        count = MIN([list count] / PREVIEW_DIV, count);
        return count;
    }
    return 0;
}

- (void)playDrawdata:(Draw *)drawData endIndex:(NSInteger)endIndex
{
    ReplayView *replay = [ReplayView createReplayView];
    if(endIndex != 0){
        [replay setEndIndex:endIndex];
        [replay setPlayControlsDisable:YES];
        [replay setDrawFeed:self.feed];
    }else{
        replay.popControllerWhenClose = YES;
    }
    self.feed.drawImage = self.contentImageView.image;
    [replay showInController:self
              withActionList:drawData.drawActionList
                isNewVersion:[drawData isNewVersion]
                        size:drawData.canvasSize];

}

- (void)playDrawToEnd:(BOOL)end
{
    
    __block LearnDrawPreViewController *cp = self;

    
    dispatch_block_t playBlock = ^{
        NSInteger index = 0;
        if (!end) {
            index = [cp previewActionCountOfFeed:cp.feed];
        }
        [cp playDrawdata:cp.feed.drawData endIndex:index];
        
        if (end) {
            ShareAction *share = [[ShareAction alloc] initWithFeed:cp.feed
                                                             image:cp.contentImageView.image];
            [share saveToLocal];
            [share release];
        }
    };
    
    
    if (self.feed.drawData) {
        playBlock();
        return;
    }

    [self showProgressViewWithMessage:NSLS(@"kLoading")];
    [[FeedService defaultService] getPBDrawByFeed:self.feed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
        if (resultCode == 0 && pbDrawData) {
            cp.feed.pbDrawData = pbDrawData;
            [cp.feed parseDrawData];
            playBlock();
            
        }else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNetworkError") delayTime:1.5 isSuccessful:NO];

        }
        
        [cp hideProgressView];
        
    } downloadDelegate:self];

}

// progress download delegate
- (void)setProgress:(CGFloat)progress
{
    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }
    
    NSString* progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    [self.progressView setLabelText:progressText];
    [self.progressView setProgress:progress];
}

- (IBAction)clickPreview:(id)sender {
    PPDebug(@"clickPreview");
    [self playDrawToEnd:NO];
}

- (IBAction)clickBuyButton:(id)sender {
    
    __block LearnDrawPreViewController *cp = self;
    [[LearnDrawService defaultService] buyLearnDraw:cp.feed.feedId
                                              price:cp.feed.learnDraw.price
                                           fromView:self.view
                                      resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
        if (resultCode == 0) {
            [cp playDrawToEnd:YES];
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBuyLearnDrawSuccess") delayTime:1.5 isSuccessful:YES];
        }else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNetworkError") delayTime:1.5 isSuccessful:NO];
        }
        
    }];
}

//dream avatar
#pragma mark - dream avatar

- (void)clickSaveToAlbum:(id)sender
{
    if ([[LearnDrawManager defaultManager] hasBoughtDraw:self.feed.feedId]) {
        [self saveToAlbum];
        return;
    }
    
    __block LearnDrawPreViewController *cp = self;
    [[LearnDrawService defaultService] buyLearnDraw:cp.feed.feedId
                                              price:cp.feed.learnDraw.price
                                           fromView:self.view
                                      resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
                                          if (resultCode == 0) {
                                              [cp saveToAlbum];
                                              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBuyLearnDrawSuccess") delayTime:1.5 isSuccessful:YES];
                                          }else{
                                              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNetworkError") delayTime:1.5 isSuccessful:NO];
                                          }
                                      }];
}

- (void)clickSaveToAvatar:(id)sender
{
    if ([[LearnDrawManager defaultManager] hasBoughtDraw:self.feed.feedId]) {
        [self saveToAvatar];
        return;
    }
    
    __block LearnDrawPreViewController *cp = self;
    [[LearnDrawService defaultService] buyLearnDraw:cp.feed.feedId
                                              price:cp.feed.learnDraw.price
                                           fromView:self.view
                                      resultHandler:^(NSDictionary *dict, NSInteger resultCode) {
                                          if (resultCode == 0) {
                                              [cp saveToAvatar];
                                              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBuyLearnDrawSuccess") delayTime:1.5 isSuccessful:YES];
                                          }else{
                                              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNetworkError") delayTime:1.5 isSuccessful:NO];
                                          }
                                      }];
}

- (void)saveToAlbum
{
    [self showActivityWithText:NSLS(@"kSaving")];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    if (queue == NULL){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    dispatch_async(queue, ^{
        UIImageWriteToSavedPhotosAlbum(_contentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.5];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (error != NULL){
        // Show error message...
    } else{
        // Show message image successfully saved
    }
}

- (void)saveToAvatar
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    PPDebug(@"shouldContinueAfterSelectingPerson");
    
    [self showActivityWithText:NSLS(@"kSaving")];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    if (queue == NULL){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    dispatch_async(queue, ^{
        UIImage *image = _contentImageView.image;
        NSData *data=UIImagePNGRepresentation(image);
        ABPersonRemoveImageData(person, NULL);
        ABAddressBookAddRecord(peoplePicker.addressBook, person, nil);
        ABAddressBookSave(peoplePicker.addressBook, nil);
        CFDataRef cfData=CFDataCreate(NULL, [data bytes], [data length]);
        ABPersonSetImageData(person, cfData, nil);
        ABAddressBookAddRecord(peoplePicker.addressBook, person, nil);
        ABAddressBookSave(peoplePicker.addressBook, nil);
    });
    [self performSelector:@selector(hideActivity) withObject:nil afterDelay:1.5];
    
    [peoplePicker dismissModalViewControllerAnimated:YES];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
