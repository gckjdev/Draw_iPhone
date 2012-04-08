//
//  ShareGifController.m
//  Draw
//
//  Created by Orange on 12-4-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareGifController.h"
#import "GifManager.h"
#import "GifView.h"
#import "SinaSNSService.h"
#import "QQWeiboService.h"
#import "FacebookSNSService.h"
#import "ShareImageManager.h"
#import "LocaleUtils.h"

#define GIF_PATH [NSString stringWithFormat:@"%@/tempory.gif", NSTemporaryDirectory()]


@interface ShareGifController ()

@end

@implementation ShareGifController
@synthesize gifFrames = _gifFrames;
@synthesize inputBackground = _inputBackground;
@synthesize shareButton = _shareButton;

- (void)dealloc
{
    [_gifFrames release];
    [_inputBackground release];
    [_shareButton release];
    [super dealloc];
}
#pragma mark Navigation Controller

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}
#pragma mark - UIActionSheetDelegate
enum {
    SHARE_VIA_EMAIL = 0,
    SHARE_VIA_SINA,
    SHARE_VIA_QQ
};
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SHARE_VIA_EMAIL: {
            
        } break;
        case SHARE_VIA_SINA: {
            
        } break;
        case SHARE_VIA_QQ: {
            
        } break;
        default:
            break;
    }
}

- (id)initWithGifFrames:(NSArray*)frames
{
    self = [super init];
    if (self) {
        self.gifFrames = frames;
    }
    return self;
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)publish:(id)sender
{
    if ([LocaleUtils isChina]) {
        UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_via") delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kShare_via_Email") otherButtonTitles:NSLS(@"kShare_via_Sina_weibo"), NSLS(@"kShare_via_tencent_weibo"), nil];
        [shareOptions showInView:self.view];
        [shareOptions release];
    } else {
        UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_via") delegate:self cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:NSLS(@"kShare_via_Email") otherButtonTitles:NSLS(@"kShare_via_Facebook"), NSLS(@"kShare_via_Twitter"), nil];
        [shareOptions showInView:self.view];
        [shareOptions release];
    }
}

- (void)didLogin:(int)result userInfo:(NSDictionary*)userInfo
{
    NSLog(@"user did login");
}
- (void)didPublishWeibo:(int)result
{
    NSLog(@"publish weibo success");
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
    [self.shareButton setTitle:NSLS(@"kShare") forState:UIControlStateNormal];
    [self.inputBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    [GifManager createGifToPath:GIF_PATH byImages:self.gifFrames];
    GifView* view = [[GifView alloc] initWithFrame:CGRectMake(16, 120, 288, 323) filePath:GIF_PATH playTimeInterval:0.5];
    [self.view addSubview:view];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setGifFrames:nil];
    [self setInputBackground:nil];
    [self setShareButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
