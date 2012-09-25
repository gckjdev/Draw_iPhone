//
//  StatementController.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StatementController.h"
#import "ShareImageManager.h"
#import "Contest.h"
#import "OfflineDrawViewController.h"

@implementation StatementController
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel;
@synthesize declineButton = _declineButton;
@synthesize acceptButton = _acceptButton;
@synthesize contest = _contest;


- (void)dealloc
{
    PPRelease(_contest);
    PPRelease(_titleLabel);
    PPRelease(_declineButton);
    PPRelease(_acceptButton);
    PPRelease(_contentView);
    [super dealloc];
}

- (id)initWithContest:(Contest *)contest
{
    self = [super init];
    if (self) {
        self.contest = contest;
    }
    return self;
}

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

- (void)initViews
{
    [self.titleLabel setText:NSLS(@"kStatement")];
    [self.declineButton setBackgroundImage:[[ShareImageManager defaultManager] redImage] forState:UIControlStateNormal];
    [self.acceptButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
    [self.declineButton setTitle:NSLS(@"kDecline") forState:UIControlStateNormal];
    [self.acceptButton setTitle:NSLS(@"kAccept") forState:UIControlStateNormal];
}

- (void)loadWebView
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.contest.statementUrl]];
    [self.contentView loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self loadWebView];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setDeclineButton:nil];
    [self setAcceptButton:nil];
    [self setContentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickDeclineButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)acceptButton:(id)sender {

}
@end
