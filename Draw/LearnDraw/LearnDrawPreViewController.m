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


@interface LearnDrawPreViewController ()

@property (assign, nonatomic) UIImage* placeHolderImage;
@property (assign, nonatomic) DrawFeed* feed;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *contentImageView;
@property (retain, nonatomic) IBOutlet UIButton *previewButton;
@property (retain, nonatomic) IBOutlet UIButton *buyButton;

- (IBAction)clickPreview:(id)sender;
- (IBAction)clickBuyButton:(id)sender;
- (IBAction)clickClose:(id)sender;

@end

@implementation LearnDrawPreViewController


+ (LearnDrawPreViewController *)presentLearnDrawPreviewControllerFrom:(UIViewController *)fromController
                                                             drawFeed:(DrawFeed *)drawFeed
                                                     placeHolderImage:(UIImage *)image
{
    LearnDrawPreViewController *ldp = [[[LearnDrawPreViewController alloc] init] autorelease];
    [ldp setFeed:drawFeed];
    [ldp setPlaceHolderImage:image];
    [fromController presentModalViewController:ldp animated:YES];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    PPDebug(@"%@ dealloc", self);
    [_titleLabel release];
    [_contentImageView release];
    [_previewButton release];
    [_buyButton release];
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
    [self dismissModalViewControllerAnimated:YES];
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

- (IBAction)clickPreview:(id)sender {
    PPDebug(@"clickPreview");
    __block LearnDrawPreViewController *cp = self;
    [[FeedService defaultService] getPBDrawByFeed:self.feed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
        if (resultCode == 0 && pbDrawData) {
            ReplayView *replay = [ReplayView createReplayView];
            feed.pbDrawData = pbDrawData;
            if (feed.drawData == nil) {
                [feed parseDrawData];
            }
            [replay setEndIndex:[cp previewActionCountOfFeed:feed]];
            [replay showInController:cp
                      withActionList:feed.drawData.drawActionList
                        isNewVersion:[feed.drawData isNewVersion]
                                size:feed.drawData.canvasSize];
        }else{
            //TODO show error message
        }
    } downloadDelegate:nil]; //TODO show download progress...
}

- (IBAction)clickBuyButton:(id)sender {
    
    
//    BalanceNotEnoughAlertView *view = []
//    PPDebug(@"clickBuyButton");
}
@end
