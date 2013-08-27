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
@synthesize declineLabel = _declineLabel;
@synthesize acceptLabel = _acceptLabel;
@synthesize contest = _contest;
@synthesize superController = _superController;

- (void)dealloc
{
    PPRelease(_contest);
    PPRelease(_acceptLabel);
    PPRelease(_declineLabel);
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
    [self.declineLabel setText:NSLS(@"kDecline")];
    [self.acceptLabel setText:NSLS(@"kAccept")];

    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setTitle:NSLS(@"kStatement")];
    [titleView setBackButtonSelector:@selector(clickDeclineButton:)];
    [titleView setRightButtonTitle:NSLS(@"kAccept")];
    [titleView setRightButtonSelector:@selector(acceptButton:)];
    [titleView setBackButtonSelector:@selector(clickDeclineButton:)];
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
    [self setContentView:nil];
    [self setDeclineLabel:nil];
    [self setAcceptLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickDeclineButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)acceptButton:(id)sender {
    [OfflineDrawViewController startDrawWithContest:self.contest
                                     fromController:self startController:self.superController animated:YES];
}
@end
