//
//  FeedController.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedController.h"
#import "Feed.h"
#import "LocaleUtils.h"
#import "PPDebug.h"
#import "ShareImageManager.h"


@implementation FeedController
@synthesize myFeedButton;
@synthesize allFeedButton;
@synthesize hotFeedButton;
@synthesize titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setSupportRefreshFooter:YES];
    [self setSupportRefreshHeader:YES];
    //init lable and button
    [self.titleLabel setText:NSLS(@"kFeedTitle")];
    [self.allFeedButton setTitle:NSLS(@"kAllFeed") forState:UIControlStateNormal];
    [self.hotFeedButton setTitle:NSLS(@"kHotFeed") forState:UIControlStateNormal];
    [self.myFeedButton setTitle:NSLS(@"kMyFeed") forState:UIControlStateNormal];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [self.hotFeedButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.hotFeedButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    [self.allFeedButton setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
    [self.allFeedButton setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
    self.allFeedButton.selected = YES;
    
    self.myFeedButton.tag = FeedListTypeMy;
    self.allFeedButton.tag = FeedListTypeAll;
    self.hotFeedButton.tag = FeedListTypeHot;
    
    [super viewDidLoad];
    
//    [[FeedService defaultService] getFeedList:FeedListTypeMy offset:0 limit:50 delegate:self];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setMyFeedButton:nil];
    [self setAllFeedButton:nil];
    [self setHotFeedButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList resultCode:(NSInteger)resultCode
{
    PPDebug(@"feedList = %@", [feedList description]);
//    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)dealloc {
    [titleLabel release];
    [myFeedButton release];
    [allFeedButton release];
    [hotFeedButton release];
    [super dealloc];
}
- (IBAction)clickFeedButton:(id)sender {
    NSInteger tag = [(UIButton *)sender tag];
    myFeedButton.selected = allFeedButton.selected = hotFeedButton.selected = NO;
    UIButton *button = (UIButton *)[self.view viewWithTag:tag];
    button.selected = YES;
    //get list
}
@end
