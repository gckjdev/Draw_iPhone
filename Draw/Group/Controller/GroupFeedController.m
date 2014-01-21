//
//  GroupFeedController.m
//  Draw
//
//  Created by Gamy on 14-1-21.
//
//

#import "GroupFeedController.h"
#import "FeedCell.h"
#import "FeedService.h"
#import "ShowFeedController.h"
#import "UseItemScene.h"

@interface GroupFeedController ()

@end

@implementation GroupFeedController

- (void)dealloc
{
    PPRelease(_groupId);
    [super dealloc];
}

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
    [self.titleView setTitle:NSLS(@"kGroupTimeline")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)serviceLoadDataWithOffset:(NSInteger)offset limit:(NSInteger)limit callback:(void (^)(NSInteger, NSArray *))callback
{
    if (_groupId) {
        [self showActivityWithText:NSLS(@"kLoading")];
        [[FeedService defaultService] getGroupFeedList:_groupId offset:offset limit:limit completed:^(int resultCode, NSArray *feedList) {
            EXECUTE_BLOCK(callback, resultCode, feedList);
            [self hideActivity];
        }];
    }else{
        NSLog(@"group id is null");
    }
}

- (Feed *)feedAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tabDataList[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FeedCell getCellHeight:[self feedAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Feed *feed = [self feedAtIndexPath:indexPath];
    DrawFeed *drawFeed = nil;
    if (feed.isOpusType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.isGuessType){
        drawFeed = [(GuessFeed *)feed drawFeed];
    }else{
        PPDebug(@"warnning:<MyFeedController> feedId = %@ is illegal feed, cannot set the detail", feed.feedId);
        return;
    }
    ShowFeedController *sfc = [[ShowFeedController alloc] initWithFeed:drawFeed scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:drawFeed]];
    sfc.feedList = [[self currentTab] dataList];
    [self.navigationController pushViewController:sfc animated:YES];
    [sfc release];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [tableView dequeueReusableCellWithIdentifier:[FeedCell getCellIdentifier]];
    if (cell == nil) {
        cell  = [FeedCell createCell:self];
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    Feed *feed = [self feedAtIndexPath:indexPath];
    [feed updateDesc]; 
    [cell setCellInfo:feed];

    return cell;
}

- (NSString *)noDataTips
{
    return NSLS(@"kNoFeedTips");
}

@end
