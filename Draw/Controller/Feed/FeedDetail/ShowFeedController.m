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
#import "CommonUserInfoView.h"
#import "OfflineGuessDrawController.h"
#import "CommentController.h"

@implementation ShowFeedController
@synthesize titleLabel = _titleLabel;
@synthesize guessButton = _guessButton;
@synthesize saveButton = _saveButton;
@synthesize commentButton = _commentButton;
@synthesize flowerButton = _flowerButton;
@synthesize tomatoButton = _tomatoButton;
@synthesize feed = _feed;
@synthesize userCell = _userCell;
@synthesize drawCell = _drawCell;
@synthesize commentHeader = _commentHeader;

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
    PPRelease(_commentHeader);
    [_titleLabel release];
    [_guessButton release];
    [_saveButton release];
    [_commentButton release];
    [_flowerButton release];
    [_tomatoButton release];
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

enum{
  ActionTagGuess = 100,
  ActionTagComment, 
  ActionTagSave,
  ActionTagFlower,
  ActionTagTomato,
  ActionTagEnd,
};

#define SCREEN_WIDTH ([DeviceDetection isIPAD] ? 768 : 320)
#define ACTION_BUTTON_Y 422
- (void)updateActionButtons
{
    //data is nil
    NSInteger start = ActionTagGuess;
    NSInteger count = ActionTagEnd - start;
    if (self.feed.drawData == nil) {
        
    }else if ([self.feed showAnswer]) {
    //mine or correct
        start = ActionTagComment;
        self.guessButton.hidden = YES;
        count --;
    }else{
        self.guessButton.hidden = NO;
    }
    
    CGFloat width = self.guessButton.frame.size.width;
    CGFloat space = (SCREEN_WIDTH - (count * width)) / (count + 1);
    CGFloat x = space;
    CGFloat y = ACTION_BUTTON_Y;
    
    for (NSInteger tag = start; tag < ActionTagEnd; ++ tag) {
        UIButton *button = (UIButton *)[self.view viewWithTag:tag];
        button.frame = CGRectMake(x, y, width, width);
        button.enabled = YES;
        x += width + space;
    }
    //can guess
    

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
    if(section == SectionCommentInfo)
    {
        if (self.commentHeader == nil) {
            self.commentHeader = [CommentHeaderView createCommentHeaderView:self];
            [self.commentHeader setViewInfo:self.feed];
        }
        return self.commentHeader;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
            [CommonUserInfoView showUser:self.feed.author.userId 
                                nickName:nil 
                                  avatar:nil 
                                  gender:nil 
                                location:nil 
                                   level:1
                                 hasSina:NO 
                                   hasQQ:NO 
                             hasFacebook:NO 
                              infoInView:self];

            break;
            
        default:
            break;
    }
}

#pragma mark update views
- (void)updateTitle
{
    NSString *title = nil;
    if ([self.feed showAnswer]) {
        title = [NSString stringWithFormat:NSLS(@"[%@]"),
                 self.feed.wordText];        
    }else{
        title = [NSString stringWithFormat:NSLS(@"kFeedDetail")];
    }
    [self.titleLabel setText:title];
}

- (void)updateCommentList:(FeedType)type
{
    [[FeedService defaultService] getOpusCommentList:self.feed.feedId offset:0 limit:20 delegate:self];
}


#pragma mark - cell delegate
- (void)didUpdateShowView
{
    //update the times
    [self.commentHeader setViewInfo:self.feed];
    //update the action buttons
    [self updateActionButtons];
    [self updateTitle];
//    [self hideActivity];
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


#pragma mark - Click Actions
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickActionButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == self.guessButton) {
        //enter guess controller
        [OfflineGuessDrawController startOfflineGuess:self.feed fromController:self];        

    }else if(button == self.commentButton){
        //enter comment controller
        CommentController *cc = [[CommentController alloc] init];
        [self presentModalViewController:cc animated:YES];
        [cc release];
    }else if(button == self.saveButton){
        //save
    }else if(button == self.flowerButton){
        //send a flower
    }else if(button == self.tomatoButton){
        //send a tomato
    }else{
        //no action
    }
    
}

- (IBAction)clickRefresh:(id)sender {
    [self.drawCell setCellInfo:self.feed];
    [self updateTitle];
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
    [self updateActionButtons];
    [self updateTitle];
    [self updateCommentList:FeedTypeComment];
//    [self showActivityWithText:NSLS(@"kLoading")];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setGuessButton:nil];
    [self setSaveButton:nil];
    [self setCommentButton:nil];
    [self setFlowerButton:nil];
    [self setTomatoButton:nil];
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
