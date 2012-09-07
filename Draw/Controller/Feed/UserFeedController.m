//
//  UserFeedController.m
//  Draw
//
//  Created by  on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserFeedController.h"
#import "ShareImageManager.h"
#import "FeedManager.h"
#import "CommonMessageCenter.h"
#import "MobClickUtils.h"
#import "ShowFeedController.h"

@interface UserFeedController()
{   NSInteger _opusStartIndex;
    NSInteger _feedStartIndex;
    NSString *_userId;
    NSString *_nickName;
    
    NSMutableArray *_feedList;
    NSMutableArray *_opusList;
    BOOL _noMoreFeed;
    BOOL _noMoreOpus;
    
}
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, retain) NSString *nickName;

- (void)updateFeedList;

@end

@implementation UserFeedController
@synthesize opusButton = _opusButton;
@synthesize feedButton = _feedButton;
@synthesize noFeedTipsLabel = _noFeedTipsLabel;
@synthesize titleLabel = _titleLabel;
@synthesize userId = _userId;
@synthesize nickName = _nickName;

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

- (void)dealloc
{
    PPRelease(_noFeedTipsLabel);
    PPRelease(_titleLabel);
    PPRelease(_userId);
    PPRelease(_nickName);
    PPRelease(_feedList);
    PPRelease(_opusList);
    PPRelease(_opusButton);
    PPRelease(_feedButton);
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId nickName:(NSString *)nickName
{
    self = [super init];
    if(self)
    {
        self.userId = userId;
        self.nickName = nickName;
        _opusStartIndex = _feedStartIndex = 0;
        _noMoreOpus = _noMoreFeed = NO;
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSupportRefreshFooter:YES];
    [self setSupportRefreshHeader:YES];
    [super viewDidLoad];
    //init lable and button
    [self.noFeedTipsLabel setText:NSLS(@"kNoFeedTips")];
    NSString *title = nil;
    
    if ([[UserManager defaultManager] isMe:_userId]) {
        title = NSLS(@"kMyFeedList");
    }else{
//        title = [NSString stringWithFormat:NSLS(@"kUserFeedTitle"), self.nickName];
        title = self.nickName;
    }
    ShareImageManager *imageManager = [ShareImageManager defaultManager];

    [self.opusButton setTitle:NSLS(@"kUserOpus") forState:UIControlStateNormal];
    [self.feedButton setTitle:NSLS(@"kUserFeed") forState:UIControlStateNormal];

    [self.opusButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [self.opusButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];

    [self.feedButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [self.feedButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];

    self.opusButton.tag = FeedListTypeUserOpus;
    self.feedButton.tag = FeedListTypeUserFeed;
    
    [self clickTabButton:self.opusButton];

    [self.titleLabel setText:title];
//    [self updateFeedList];
}

- (void)viewDidUnload
{
    [self setOpusButton:nil];
    [self setFeedButton:nil];
    [super viewDidUnload];
    [self setNoFeedTipsLabel:nil];
    [self setTitleLabel:nil];
    [self setUserId:nil];
}

#define FEED_COUNT [MobClickUtils getIntValueByKey:@"FEED_PER_PAGE" defaultValue:12]

- (void)updateFeedList
{
    [self showActivityWithText:NSLS(@"kLoading")];
    if (self.opusButton.selected) {
        [[FeedService defaultService] getUserOpusList:self.userId
                                               offset:_opusStartIndex 
                                                limit:FEED_COUNT 
                                             delegate:self];
    }else{
        [[FeedService defaultService] getUserFeedList:self.userId
                                               offset:_feedStartIndex
                                                limit:FEED_COUNT 
                                             delegate:self];
    }

}

- (FeedListType)currentType
{
    if (self.opusButton.selected) {
        return FeedListTypeUserOpus;
    }
    return FeedListTypeUserFeed;
}

- (void)reloadView
{
    if ([self currentType] == FeedListTypeUserFeed) {
        self.noMoreData = _noMoreFeed;
    }else{
        self.noMoreData = _noMoreOpus;
    }
    [self.dataTableView reloadData];
}

#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId 
                  type:(FeedListType)type
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
    
    if ([feedList count] == 0) {
        if (type == FeedListTypeUserFeed) {
            _noMoreFeed = YES;
        }else{
            _noMoreOpus = YES;
        }
    }else{
        if (type == FeedListTypeUserFeed) {
            if (_feedList == nil) {
                _feedList = [[NSMutableArray alloc] initWithArray:feedList];
            }else{
                if (_feedStartIndex == 0) {
                    [_feedList removeAllObjects];
                }
                [_feedList addObjectsFromArray:feedList];
            }
            _feedStartIndex += [feedList count];
            _noMoreFeed = NO;
        }else{
            if (_opusList == nil) {
                _opusList = [[NSMutableArray alloc] initWithArray:feedList];
            }else{
                if (_opusStartIndex == 0) {
                    [_opusList removeAllObjects];
                }
                [_opusList addObjectsFromArray:feedList];
            }        
            _opusStartIndex += [feedList count];
            _noMoreOpus = NO;
        }
    }
    if ([self currentType] == type) {
        [self reloadView];
    }

}


#pragma mark - override for reload data

- (void)reloadTableViewDataSource
{
    if ([self currentType] == FeedListTypeUserFeed) {
        _feedStartIndex = 0;
    }
    if ([self currentType] == FeedListTypeUserOpus) {
        _opusStartIndex = 0;
    }
    [self updateFeedList];
}

- (void)loadMoreTableViewDataSource
{
    [self updateFeedList];
}



#pragma mark - click action
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickRefreshButton:(id)sender {
    [self reloadTableViewDataSource];
}

- (IBAction)clickTabButton:(id)sender {
    self.opusButton.selected = self.feedButton.selected = NO;
    UIButton *button = (UIButton *)sender;
    button.selected = YES;
    [self reloadView];
    if (button.tag == FeedListTypeUserOpus && _opusList == nil) {
        [self updateFeedList];
    }else if (_feedList == nil) {
        [self updateFeedList];
    }
}

#pragma mark - table view delegate

- (NSArray *)dataList
{
    if ([self currentType] == FeedListTypeUserOpus) {
        return _opusList;
    }else{
        return _feedList;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [FeedCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger count = [self.dataList count];
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
        PPDebug(@"warnning:<UserFeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];
    //enter the detail feed contrller
}


@end
