//
//  GifViewController.m
//  Draw
//
//  Created by 黄毅超 on 14-7-30.
//
//

#import "GifViewController.h"

@interface GifViewController ()

@end

@implementation GifViewController
@synthesize gifData;

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
    // Do any additional setup after loading the view.

    [self showGif];
    
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    POSTMSG(@"Why?!");
}

- (void) singleTab:(id)sender
{
    POSTMSG(@"is tab");
}

-(void)showGif
{
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    
    [self getGifDataFromPath:@"/Users/Linruin/Desktop/test.gif"];
    [self displayGifImageInSize:rect];
    
}

- (void) getGifDataFromPath:(NSString*) path
{
    gifData = [NSData dataWithContentsOfFile:path];
    PPDebug(@"put in Gif data success!");
}

- (void) displayGifImageInSize:(CGRect)rect
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:rect];
    UITapGestureRecognizer *tabGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTab:)];
    [webView addGestureRecognizer:tabGesture];
    [tabGesture release];
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    webView.scalesPageToFit = YES;
    [webView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    [self.view addSubview:webView];
    [webView release];
}

@end
