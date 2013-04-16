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

@interface LearnDrawPreViewController ()

@property (retain, nonatomic) UIImage* placeHolderImage;
@property (retain, nonatomic) DrawFeed* feed;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *contentImageView;
@property (retain, nonatomic) IBOutlet UIButton *previewButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;

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
    [self.previewButton setTitle:NSLS(@"kLearnDrawPreview") forState:UIControlStateNormal];
    [self.buyButton setTitle:NSLS(@"kLearnDrawBuy") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    PPRelease(_placeHolderImage);
    PPRelease(_feed);
    
    PPRelease(_titleLabel);
    PPRelease(_contentImageView);
    PPRelease(_previewButton);
    PPRelease(_buyButton);
    _feed.drawData = nil;
    PPRelease(_feed);
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setContentImageView:nil];
    [self setPreviewButton:nil];
    [self setBuyButton:nil];
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
    }
    self.feed.drawImage = self.contentImageView.image;
    [replay showInController:self
              withActionList:drawData.drawActionList
                isNewVersion:[drawData isNewVersion]
                        size:drawData.canvasSize];

}

- (void)playDrawToEnd:(BOOL)end
{
    if (self.feed.drawData) {
        [self playDrawdata:self.feed.drawData
                  endIndex:[self previewActionCountOfFeed:self.feed]];
        return;
    }
    
    __block LearnDrawPreViewController *cp = self;
    [[FeedService defaultService] getPBDrawByFeed:self.feed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
        if (resultCode == 0 && pbDrawData) {
            cp.feed.pbDrawData = pbDrawData;
            [cp.feed parseDrawData];
            NSInteger index = 0;
            if (!end) {
                index = [self previewActionCountOfFeed:cp.feed];
            }
            [cp playDrawdata:feed.drawData endIndex:index];
            
            if (end) {
                ShareAction *share = [[ShareAction alloc] initWithFeed:cp.feed
                                                                 image:cp.contentImageView.image];
                [share saveToLocal];
                [share release];
            }
            
        }else{
            //TODO show error message
        }
    } downloadDelegate:nil]; //TODO show download progress...

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
            
        }else{
            //TODO deal with the error result.
        }
        
    }];
}
@end
