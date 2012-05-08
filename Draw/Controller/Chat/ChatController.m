//
//  ChatController.m
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatController.h"

@interface ChatController ()

@end

@implementation ChatController
@synthesize headImageHolderView;
@synthesize headView;
@synthesize nameLabel;
@synthesize sexLabel;
@synthesize cityLabel;
@synthesize microBlogImageView;
@synthesize expressionScrollView;
@synthesize messageTableView;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setHeadView:nil];
    [self setNameLabel:nil];
    [self setSexLabel:nil];
    [self setCityLabel:nil];
    [self setExpressionScrollView:nil];
    [self setMessageTableView:nil];
    [self setHeadImageHolderView:nil];
    [self setMicroBlogImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [headView release];
    [nameLabel release];
    [sexLabel release];
    [cityLabel release];
    [expressionScrollView release];
    [messageTableView release];
    [headImageHolderView release];
    [microBlogImageView release];
    [super dealloc];
}

- (IBAction)clickPayAttentionButton:(id)sender {
}
@end
