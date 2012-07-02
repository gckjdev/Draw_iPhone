//
//  FeedController.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedController.h"
#import "Feed.h"
#import "FeedManager.h"
#import "LocaleUtils.h"
#import "PPDebug.h"
#import "ShareImageManager.h"
#import "FeedCell.h"
#import "CommonMessageCenter.h"
#import "FeedDetailController.h"
#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"
#import "UserFeedController.h"
#import "MobClickUtils.h"
#import "CommonUserInfoView.h"

#pragma mark - Class FeedListState
@interface FeedListState : NSObject {
    NSInteger _startIndex;
    BOOL _hasLoadData;
}
@property(nonatomic, assign) NSInteger startIndex;
@property(nonatomic, assign) BOOL hasLoadData;
+ (NSInteger)loadDataCount;
- (id)init;
+ (FeedListState *)feedListState;
@end


@implementation FeedListState
@synthesize startIndex = _startIndex;
@synthesize hasLoadData = _hasLoadData;


+ (FeedListState *)feedListState
{
    return [[[FeedListState alloc] init]autorelease];
}
- (id)init
{
    self = [super init];
    if (self) {
        self.startIndex = 0;
        self.hasLoadData = NO;
    }
    return self;
}

+ (NSInteger)loadDataCount
{
    return [MobClickUtils getIntValueByKey:@"FEED_PER_PAGE" defaultValue:12];
}
@end


#pragma mark - Class FeedController

@implementation FeedController
@synthesize noFeedTipsLabel;
@synthesize titleLabel;
@synthesize myFeedButton;
@synthesize allFeedButton;
@synthesize hotFeedButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _feedListStats = [[NSArray  alloc] initWithObjects:
                          [FeedListState feedListState],
                          [FeedListState feedListState],
                          [FeedListState feedListState], nil];
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
    [super viewDidLoad];
    //init lable and button
    [self.noFeedTipsLabel setText:NSLS(@"kNoFeedTips")];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.titleLabel setText:NSLS(@"kFeedTitle")];
    [self.allFeedButton setTitle:NSLS(@"kAllFeed") forState:UIControlStateNormal];
    [self.hotFeedButton setTitle:NSLS(@"kHotFeed") forState:UIControlStateNormal];
    [self.myFeedButton setTitle:NSLS(@"kMyFeed") forState:UIControlStateNormal];
    
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [self.hotFeedButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.hotFeedButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    [self.allFeedButton setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
    [self.allFeedButton setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
    self.myFeedButton.tag = FeedListTypeMy;
    self.allFeedButton.tag = FeedListTypeAll;
    self.hotFeedButton.tag = FeedListTypeHot;
    [self clickFeedButton:self.allFeedButton];
    
//    [[FeedService defaultService] getFeedList:FeedListTypeMy offset:0 limit:50 delegate:self];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setMyFeedButton:nil];
    [self setAllFeedButton:nil];
    [self setHotFeedButton:nil];
    [self setNoFeedTipsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [titleLabel release];
    [myFeedButton release];
    [allFeedButton release];
    [hotFeedButton release];
    [_feedListStats release];
    [noFeedTipsLabel release];
    [super dealloc];
}



#pragma mark - feed list state

- (FeedListState *)feedListStateForType:(FeedListType)type
{
    if (type == FeedListTypeMy) {
        return [_feedListStats objectAtIndex:0];
    }else if(type == FeedListTypeAll)
    {
        return [_feedListStats objectAtIndex:1];
    }else if(type == FeedListTypeHot)
    {
        return [_feedListStats objectAtIndex:2];
    }
    return nil;
}

- (BOOL)hasLoadDataForType:(FeedListType)type
{
    FeedListState *stat = [self feedListStateForType:type];
    return [stat hasLoadData];
}

- (NSInteger)startIndexForType:(FeedListType )type
{
    FeedListState *stat = [self feedListStateForType:type];
    return [stat startIndex];    
}

- (void)setloadDataFlag:(BOOL)flag forType:(FeedListType)type
{
    FeedListState *stat = [self feedListStateForType:type];
    [stat setHasLoadData:flag];    
}

- (void)setloadDataStartIndex:(NSInteger)startIndex forType:(FeedListType)type
{
    FeedListState *stat = [self feedListStateForType:type];
    [stat setStartIndex:startIndex];   
}


- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[FeedManager defaultManager] cleanData];
}


- (void)updateFeedListForType:(FeedListType)type
{
    FeedListState *stat = [self feedListStateForType:type];
    if (stat) {
        [self showActivityWithText:NSLS(@"kLoading")];
        [[FeedService defaultService] getFeedList:type 
                                           offset:stat.startIndex 
                                            limit:[FeedListState loadDataCount] 
                                         delegate:self];
    }
}

- (IBAction)clickFeedButton:(id)sender {
    NSInteger tag = [(UIButton *)sender tag];
    myFeedButton.selected = allFeedButton.selected = hotFeedButton.selected = NO;
    UIButton *button = (UIButton *)[self.view viewWithTag:tag];
    button.selected = YES;

    self.dataList = [[FeedManager defaultManager] feedListForType:tag];
    [self.dataTableView reloadData];
    
    if (![self hasLoadDataForType:tag]) {
        [self setloadDataFlag:YES forType:tag];
        //load data
        [self updateFeedListForType:tag];
    }
    
    //get list
}

- (FeedListType)currentFeedListType
{
    if (myFeedButton.selected == YES) {
        return myFeedButton.tag;
    }
    if (allFeedButton.selected == YES) {
        return allFeedButton.tag;
    }
    if (hotFeedButton.selected == YES) {
        return hotFeedButton.tag;
    }
    return FeedListTypeAll;
}

#pragma mark - feed service delegate
- (void)didGetFeedList:(NSArray *)feedList 
          feedListType:(FeedListType)type 
            resultCode:(NSInteger)resultCode
{
    
    [self hideActivity];
    [self dataSourceDidFinishLoadingNewData];   
    [self dataSourceDidFinishLoadingMoreData];

    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGetFeedListFail") 
                                                       delayTime:1 
                                                         isHappy:NO];
        return;
    }
    

    FeedManager *feedManager = [FeedManager defaultManager];
    
    if ([feedList count] < [FeedListState loadDataCount]) {
        self.noMoreData = YES;
    }else{
        self.noMoreData = NO;
    }
    
    BOOL isReload = [self startIndexForType:type] == 0;
    
    if (isReload) {
        if (feedList) {
            [feedManager setFeedList:[NSMutableArray arrayWithArray:feedList] forType:type];
        }else{
            [feedManager setFeedList:nil forType:type];
        }
    }else{
        if (feedList) {
            [feedManager addFeedList:feedList forType:type];
        }
    }
    NSInteger newIndex = [self startIndexForType:type] + [feedList count];
    [self setloadDataStartIndex:newIndex forType:type];
    self.dataList = [feedManager feedListForType:type];
    [self.dataTableView reloadData];
    if (isReload) {
        //scroll to top.
        [self.dataTableView setContentOffset:CGPointZero animated:YES];
    }
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [FeedCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [dataList count];
    self.noFeedTipsLabel.hidden = (count != 0);
    
    if (count != 0) {
        self.dataTableView.separatorColor = [UIColor lightGrayColor];
    }else{
        self.dataTableView.separatorColor = [UIColor clearColor];
    }
    
    return count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [FeedCell getCellIdentifier];
    FeedCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [FeedCell createCell:self];
    }
    cell.indexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryNone;
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:feed];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row > [self.dataList count])
        return;
    
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    FeedDetailController *feedDetailController = [[FeedDetailController alloc] initWithFeed:feed];
    [self.navigationController pushViewController:feedDetailController animated:YES];
    [feedDetailController release];
    //enter the detail feed contrller
}



- (void)reloadTableViewDataSource
{
    FeedListType type = [self currentFeedListType];
    [self setloadDataStartIndex:0 forType:type];
    [self updateFeedListForType:type];
}

- (void)loadMoreTableViewDataSource
{
    FeedListType type = [self currentFeedListType];
    [self updateFeedListForType:type];
}


//FeedCell delegate
#pragma mark - FeedCell delegate
- (void)didClickGuessButtonOnFeed:(Feed *)feed
{
    [OfflineGuessDrawController startOfflineGuess:feed fromController:self];
}
- (void)didClickDrawOneMoreButtonAtIndexPath:(NSIndexPath *)indexPath
{
    [SelectWordController startSelectWordFrom:self gameType:OfflineDraw];
}

- (void)didClickAvatar:(NSString *)userId 
              nickName:(NSString *)nickName 
                gender:(BOOL)gender 
           atIndexPath:(NSIndexPath *)indexPath
{
    
    //for test user feed controller
//    PPDebug(@"<FeedCell delegate>: click avatar, userId = %@", userId);
//    UserFeedController *userFeed = [[UserFeedController alloc] initWithUserId:userId nickName:nickName];
//    [self.navigationController pushViewController:userFeed animated:YES];
//    [userFeed release];
    NSString* genderString = gender?@"m":@"f";
    [CommonUserInfoView showUser:userId 
                        nickName:nickName 
                          avatar:nil 
                          gender:genderString 
                        location:nil
                         hasSina:NO 
                           hasQQ:NO 
                     hasFacebook:NO 
                      infoInView:self];
}

- (IBAction)clickRefreshButton:(id)sender {
    [self reloadTableViewDataSource];
}
@end



