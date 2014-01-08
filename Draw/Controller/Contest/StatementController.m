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
#import "ContestService.h"
#import "SingController.h"
#import "StatementCell.h"

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
}

- (void)loadWebView
{
    self.contentView.hidden = NO;
    self.dataTableView.hidden = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.contest.statementUrl]];
    [self.contentView loadRequest:request];
}

- (void)loadDataTableView{
    
    self.contentView.hidden = YES;
    self.dataTableView.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    
    if ([self.contest isGroupContest]) {
        [self loadDataTableView];
    }else{
       [self loadWebView]; 
    }
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
    
    
    [[ContestService defaultService] acceptContest:self.contest.contestId];
    
    if (isSingApp()) {
        
        SingController *vc = [[[SingController alloc] initWithContest:self.contest] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (isDrawApp() || isLittleGeeAPP()){
        
        [OfflineDrawViewController startDrawWithContest:self.contest
                                         fromController:self startController:self.superController animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float height = 50;
    if (indexPath.row == 0){
        NSString *content = [[[self.contest contestingTimeDesc] stringByAppendingString:@"\n"] stringByAppendingString:[self.contest votingTimeDesc]];
        height = [StatementCell getCellHeightWithContent:content];
    }else if (indexPath.row == 1){
        height = [StatementCell getCellHeightWithContent:[self.contest title]];
    }else if (indexPath.row == 2){
        height = [StatementCell getCellHeightWithContent:[self.contest desc]];
    }else if (indexPath.row == 3){
        height = [StatementCell getCellHeightWithContent:[self.contest awardRulesDesc]];
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    StatementCell *cell = [tableView dequeueReusableCellWithIdentifier:[StatementCell getCellIdentifier]];
    if (cell == nil) {
        cell = [StatementCell createCell:self];
    }

    if (indexPath.row == 0){
        NSString *content = [[[self.contest contestingTimeDesc] stringByAppendingString:@"\n"] stringByAppendingString:[self.contest votingTimeDesc]];
        [cell setCellTitle:NSLS(@"kTime") content:content];
    }else if (indexPath.row == 1){
        [cell setCellTitle:NSLS(@"kSubject") content:[self.contest title]];
    }else if (indexPath.row == 2){
        [cell setCellTitle:NSLS(@"kDesc") content:[self.contest desc]];
    }else if (indexPath.row == 3){
        [cell setCellTitle:NSLS(@"kAward") content:[self.contest awardRulesDesc]];
    }
    
    cell.indexPath = indexPath;

    return cell;
}

@end
