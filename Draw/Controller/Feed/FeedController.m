//
//  FeedController.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedController.h"
#import "Feed.h"
@implementation FeedController

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
    [super viewDidLoad];
    [[FeedService defaultService] getFeedList:FeedListTypeMy offset:0 limit:50 delegate:self];
}

- (void)viewDidUnload
{
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
@end
