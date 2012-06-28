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
#import "FeedDetailController.h"

@interface UserFeedController()

- (void)updateFeedList;

@end

@implementation UserFeedController
@synthesize startIndex = _startIndex;
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
    [super dealloc];
}

- (id)initWithUserId:(NSString *)userId nickName:(NSString *)nickName
{
    self = [super init];
    if(self)
    {
        self.userId = userId;
        self.nickName = nickName;
        self.startIndex = 0;
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
        title = [NSString stringWithFormat:NSLS(@"kUserFeedTitle"), self.nickName];
    }


    [self.titleLabel setText:title];
    [self updateFeedList];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setNoFeedTipsLabel:nil];
    [self setTitleLabel:nil];
    [self setUserId:nil];
}

#define FEED_COUNT 20
- (void)updateFeedList
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[FeedService defaultService] getUserFeedList:self.userId offset:_startIndex limit:FEED_COUNT delegate:self];

}


#pragma mark - feed service delegate

- (void)didGetFeedList:(NSArray *)feedList 
            targetUser:(NSString *)userId
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
    
    if ([feedList count] < FEED_COUNT) {
        self.noMoreData = YES;
    }else{
        self.noMoreData = NO;
    }
    
    BOOL isReload = _startIndex == 0;

    if (isReload) {
        self.dataList = feedList;
    }else{
        if ([feedList count] != 0) {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataList];
            [temp addObjectsFromArray:feedList];
            self.dataList = temp;            
        }
    }    
    
    _startIndex += [feedList count];
    
    [self.dataTableView reloadData];
    if (isReload) {
        //scroll to top.
        [self.dataTableView setContentOffset:CGPointZero animated:YES];
    }

}


#pragma mark - override for reload data

- (void)reloadTableViewDataSource
{
    _startIndex = 0;
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


@end
