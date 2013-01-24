//
//  OpusSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "OpusSelectController.h"
#import "FeedService.h"
#import "UserManager.h"
#import "OpusCell.h"

#define EACH_FECTH_COUNT 20

@interface OpusSelectController ()
{
    int _start;
}

@end

@implementation OpusSelectController


- (void)dealloc {
    [_selectedOpusesHolderView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[FeedService defaultService] getUserOpusList:[[UserManager defaultManager] userId] offset:_start limit:EACH_FECTH_COUNT type:FeedListTypeUserOpus delegate:self];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSelectedOpusesHolderView:nil];
    [super viewDidUnload];
}


- (void)didGetFeedList:(NSArray *)feedList
            targetUser:(NSString *)userId
                  type:(FeedListType)type
            resultCode:(NSInteger)resultCode
{
    if (resultCode != 0) {
        return;
    }
    
    if (dataList == nil) {
        self.dataList = feedList;
    }else{
        self.dataList = [dataList arrayByAddingObjectsFromArray:feedList];
    }
    
    [self.dataTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [OpusCell getCellHeight];
}


- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = ([dataList count] / EACH_CELL_OPUSES_COUNT) + ([dataList count] % EACH_CELL_OPUSES_COUNT == 0 ? 0 : 1);
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpusCell *cell = [tableView dequeueReusableCellWithIdentifier:[OpusCell getCellIdentifier]];
    if (cell == nil) {
        cell = [OpusCell createCell:self];
    }

    NSRange range = NSMakeRange(indexPath.row * EACH_CELL_OPUSES_COUNT, MIN(EACH_CELL_OPUSES_COUNT, [dataList count] - indexPath.row * EACH_CELL_OPUSES_COUNT));

    [cell setCellData:[dataList subarrayWithRange:range]];
    
    return cell;
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didClickOpus:(DrawFeed *)opus
{
    PPDebug(@"didClickOpus:%@", opus.wordText);
}

@end
