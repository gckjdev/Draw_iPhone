//
//  ShowFeedController.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShowFeedController.h"
#import "CommentHeaderView.h"
#import "DrawInfoCell.h"
#import "UserInfoCell.h"
#import "CommentCell.h"
#import "CommentFeed.h"
#import "TableTabManager.h"

@implementation ShowFeedController
@synthesize titleLabel = _titleLabel;
@synthesize feed = _feed;
@synthesize userCell = _userCell;
@synthesize drawCell = _drawCell;


typedef enum{
    
    SectionUserInfo = 0,
    SectionDrawInfo,
    SectionCommentInfo,
    SectionNumber
    
}Section;

- (void)dealloc
{
    PPRelease(_feed);
    PPRelease(_drawCell);
    PPRelease(_userCell);
    PPRelease(_tabManager);
    [_titleLabel release];
    [super dealloc];
}

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if(self)
    {
        self.feed = feed;
        NSArray *array = [NSArray arrayWithObjects:@"comment", nil];
        _tabManager = [[TableTabManager alloc] initWithTabIDList:array 
                                                           limit:20 
                                                 currentTabIndex:0];
    }
    return self;
}


#pragma mark - table view delegate.

- (UITableViewCell *)cellForUserInfoSection
{
    if (self.userCell == nil) {
        self.userCell = [UserInfoCell createCell:self];
        [self.userCell setCellInfo:self.feed];
        self.userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self.userCell;
}
- (UITableViewCell *)cellForDrawInfoSection
{
    if (self.drawCell == nil) {
        self.drawCell = [DrawInfoCell createCell:self];
        [self.drawCell setCellInfo:self.feed];
    }
    return self.drawCell;

}
- (UITableViewCell *)cellForCommentInfoAtRow:(NSInteger)row
{
    NSString * identifier = [CommentCell getCellIdentifier];
    CommentCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [CommentCell createCell:self];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    CommentFeed *feed = [self.dataList objectAtIndex:row];
    [cell setCellInfo:feed];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
        {
           return [self cellForUserInfoSection];
        }
        case SectionDrawInfo:
        {
            return [self cellForDrawInfoSection];
        }
        case SectionCommentInfo:
        {
            return [self cellForCommentInfoAtRow:indexPath.row];
        }
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionUserInfo:
        case SectionDrawInfo:
            return 1;
        case SectionCommentInfo:
            return [self.dataList count];
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionNumber;    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
            return [UserInfoCell getCellHeight];
        case SectionDrawInfo:
            return [DrawInfoCell getCellHeight];
        case SectionCommentInfo:
        {
            CommentFeed *feed = [self.dataList objectAtIndex:indexPath.row];
            CGFloat height = [CommentCell getCellHeight:feed];
            return height;
        }
        default:
            return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == SectionCommentInfo) ? [CommentHeaderView getHeight] : 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return (section == SectionCommentInfo) ? [CommentHeaderView createCommentHeaderView:self] : nil;
}

#pragma mark update views
- (void)updateTitle
{
    NSString *title = nil;
    if ([self.feed isMyOpus]) {
        title = [NSString stringWithFormat:NSLS(@"kMyDrawing"),
                 self.feed.wordText];        
    }else{
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail"),_feed.feedUser.nickName];
    }
    [self.titleLabel setText:title];
}

- (void)updateCommentList:(FeedType)type
{
    [[FeedService defaultService] getOpusCommentList:self.feed.feedId offset:0 limit:20 delegate:self];
}


#pragma mark - feed service delegate

- (void)didGetFeedCommentList:(NSArray *)feedList 
                       opusId:(NSString *)opusId 
                   resultCode:(NSInteger)resultCode
{
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];
    if (resultCode == 0) {
        NSInteger count = [feedList count];
        self.noMoreData = (count == 0);        
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  succ!", opusId);
        if (_startIndex == 0) {
            self.dataList = feedList;
        }else{
            NSMutableArray *array = [NSMutableArray array];
            if ([self.dataList count] != 0) {
                [array  addObjectsFromArray:self.dataList];
            }
            if ([feedList count] != 0) {
                [array addObjectsFromArray:feedList];
            }      
            self.dataList = array;
        }
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:SectionCommentInfo];
        [self.dataTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        _startIndex += count;
    }else{
        PPDebug(@"<didGetFeedCommentList>get feed(%@)  fail!", opusId);
    }
//    [noCommentTipsLabel setText:NSLS(@"kNoCommentTips")];
}


#pragma mark - Action
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - override methods.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    [self updateTitle];
    [self updateCommentList:FeedTypeComment];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
