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

#define GIF_PATH [NSString stringWithFormat:@"%@/tempory.gif", NSTemporaryDirectory()]


@interface ShareGifController ()

@end

@implementation ShareGifController
@synthesize gifFrames = _gifFrames;

- (void)dealloc
{
    [_gifFrames release];
    [super dealloc];
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
    [[SinaSNSService defaultService] publishWeibo:@"test gif" imageFilePath:GIF_PATH delegate:self];
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
    [GifManager createGifToPath:GIF_PATH byImages:self.gifFrames];
    GifView* view = [[GifView alloc] initWithFrame:CGRectMake(0, 0, 320, 330) filePath:GIF_PATH playTimeInterval:0.5];
    [self.view addSubview:view];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setGifFrames:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
