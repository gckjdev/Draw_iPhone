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
#import "OfflineGuessDrawController.h"
#import "SelectWordController.h"
#import "UserFeedController.h"
#import "MobClickUtils.h"
#import "CommonUserInfoView.h"
#import "NotificationManager.h"
#import "ShowFeedController.h"

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
@synthesize latestFeedButton;
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
                          [FeedListState feedListState],
                          [FeedListState feedListState], nil];
        _feedManager = [[FeedManager alloc] init];
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
    [self.latestFeedButton setTitle:NSLS(@"kLatestFeed") forState:UIControlStateNormal];
    
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.myFeedButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];

    [self.allFeedButton setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
    [self.allFeedButton setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];

    
    [self.hotFeedButton setBackgroundImage:[imageManager middleTabImage] forState:UIControlStateNormal];
    [self.hotFeedButton setBackgroundImage:[imageManager middleTabSelectedImage] forState:UIControlStateSelected];
    

    [self.latestFeedButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.latestFeedButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];

    
    self.myFeedButton.tag = FeedListTypeMy;
    self.allFeedButton.tag = FeedListTypeAll;
    self.hotFeedButton.tag = FeedListTypeHot;
    self.latestFeedButton.tag = FeedListTypeLatest;
    [self clickFeedButton:self.allFeedButton];
    [self setSwipeToBack:YES];
    
//    [[FeedService defaultService] getFeedList:FeedListTypeMy offset:0 limit:50 delegate:self];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setMyFeedButton:nil];
    [self setAllFeedButton:nil];
    [self setHotFeedButton:nil];
    [self setNoFeedTipsLabel:nil];
    [self setLatestFeedButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    [[NotificationManager defaultManager] hideNotificationForType:NotificationTypeFeed];
    [super viewDidAppear:animated];
}

- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(myFeedButton);
    PPRelease(allFeedButton);
    PPRelease(hotFeedButton);
    PPRelease(_feedListStats);
    PPRelease(noFeedTipsLabel);
    PPRelease(_feedManager);
    PPRelease(latestFeedButton);
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
    }else if(type == FeedListTypeLatest){
        return [_feedListStats objectAtIndex:3];
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
    [self.navigationController popViewControllerAnimated:YES];
//    [_feedManager cleanData];
    [FeedManager releaseDefaultManager];
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
    myFeedButton.selected = allFeedButton.selected = hotFeedButton.selected = latestFeedButton.selected = NO;
    UIButton *button = (UIButton *)[self.view viewWithTag:tag];
    button.selected = YES;

    self.dataList = [_feedManager feedListForType:tag];
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
    }else if(latestFeedButton.selected)
    {
        return latestFeedButton.tag;
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

    PPDebug(@"<didGetFeedList> feed list count = %d", [feedList count]);
    
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGetFeedListFail") 
                                                       delayTime:1 
                                                         isHappy:NO];
        return;
    }
    

//    FeedManager *feedManager = _feedManager;
    
    if ([feedList count] == 0) {
        self.noMoreData = YES;
    }else{
        self.noMoreData = NO;
    }
    
    BOOL isReload = [self startIndexForType:type] == 0;
    
    if (isReload) {
        if (feedList) {
            [_feedManager setFeedList:[NSMutableArray arrayWithArray:feedList] forType:type];
        }else{
            [_feedManager setFeedList:nil forType:type];
        }
    }else{
        if (feedList) {
            [_feedManager addFeedList:feedList forType:type];
        }
    }
    NSInteger newIndex = [self startIndexForType:type] + [feedList count];
    [self setloadDataStartIndex:newIndex forType:type];
    self.dataList = [_feedManager feedListForType:type];
    if ([self currentFeedListType] == type) {
        [self.dataTableView reloadData];        
    }
    if (isReload) {
        //scroll to top.
        [self.dataTableView setContentOffset:CGPointZero animated:YES];
    }
}


- (void)didDeleteFeed:(Feed *)feed resultCode:(NSInteger)resultCode;

{
    [self hideActivity];
    if (resultCode != 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeleteFail") delayTime:1.5 isHappy:NO];
        return;
    }
    NSInteger row = [self.dataList indexOfObject:feed];
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.dataList];
    [array removeObject:feed];
    self.dataList = array;
    [self.dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
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
    [feed updateDesc];
    [cell setCellInfo:feed];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row > [self.dataList count])
        return;
    
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    
    if (feed.opusStatus == OPusStatusDelete) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kOpusDelete") delayTime:1.5 isHappy:NO];
        return;
    }
    DrawFeed *drawFeed = nil;
    if (feed.isDrawType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.isGuessType){
        drawFeed = [(GuessFeed *)feed drawFeed];
    }else{
        PPDebug(@"warnning:<FeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];

    
    //enter the detail feed contrller
}


#pragma mark - delete feed.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    [self showActivityWithText:NSLS(@"kDeleting")];
    [[FeedService defaultService] deleteFeed:feed delegate:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self.dataList objectAtIndex:indexPath.row];
    return [feed isMyFeed];
}

#pragma mark - refresh header & footer delegate
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
    if ([feed isKindOfClass:[DrawFeed class]]){
        [OfflineGuessDrawController startOfflineGuess:(DrawFeed*)feed fromController:self];
    }
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
    
    NSString* genderString = gender?@"m":@"f";
    [CommonUserInfoView showUser:userId 
                        nickName:nickName 
                          avatar:nil 
                          gender:genderString 
                        location:nil 
                           level:1
                         hasSina:NO 
                           hasQQ:NO 
                     hasFacebook:NO 
                      infoInView:self];
}

- (IBAction)clickRefreshButton:(id)sender {
    [self reloadTableViewDataSource];
}
@end



