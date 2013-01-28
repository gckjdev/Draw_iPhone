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
#import "LayoutManager.h"
#import "Layout.h"
#import "Wall.h"
#import "OpusWallController.h"

#define EACH_FECTH_COUNT 20

@interface OpusSelectController ()
{
    int _start;
}

@property (retain, nonatomic) NSMutableArray *opuses;

@end

@implementation OpusSelectController


- (void)dealloc {
    [_selectedOpusesHolderView release];
    [_opuses release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.opuses = [NSMutableArray array];
    
    [[FeedService defaultService] getUserOpusList:@"50d51066e4b0d73d234e4234" offset:_start limit:EACH_FECTH_COUNT type:FeedListTypeUserOpus delegate:self];
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

    if ([_opuses indexOfObject:opus] == NSNotFound) {
        [_opuses addObject:opus];
    }else{
        [_opuses removeObject:opus];
    }
}

//- (IBAction)clickCreateWallButton:(id)sender {
//    if ([_opuses count] < 4) {
//        [self popupMessage:@"请选够四张作品！" title:@"作品数不够"];
//        return;
//    }
//    
//    NSArray *wallOpuses = [NSArray arrayWithObjects:[WallOpus wallOpusWithFrameId:301 drawFeed:[_opuses objectAtIndex:0]],  [WallOpus wallOpusWithFrameId:302 drawFeed:[_opuses objectAtIndex:1]], [WallOpus wallOpusWithFrameId:303 drawFeed:[_opuses objectAtIndex:2]], [WallOpus wallOpusWithFrameId:304 drawFeed:[_opuses objectAtIndex:3]], nil];
//
//    PBWall_Builder *wallBuilder = [[[PBWall_Builder alloc] init] autorelease];
//    [wallBuilder setWallId:@"xxxxxx"];
//    [wallBuilder setType:PBWallTypeOpuses];
//    [wallBuilder setUserId:[[UserManager defaultManager] userId]];
//    wallBuilder setWallName:<#(NSString *)#>
//    
//    Wall *wall = [Wall wallWithWallId:@"xxxxxxx"
//                             wallType:0
//                               userId:[[UserManager defaultManager] userId]
//                             wallName:@"我的作品墙"
//                               layout:[Layout layoutFromPBLayout:[LayoutManager createTestData]]
//                           wallOpuses:wallOpuses
//                             musicUrl:nil];
//
//    
//    OpusWallController *vc = [[[OpusWallController alloc] initWithWall:wall] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
//}

@end
