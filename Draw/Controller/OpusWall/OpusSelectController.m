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
#import "Wall.h"
#import "OpusWallController.h"
#import "ProtocolUtil.h"
#import "UIViewUtils.h"
#import "UIImageView+WebCache.h"

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
    [_comfirmBtn release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.opuses = [NSMutableArray array];
    
//    [[FeedService defaultService] getUserOpusList:@"50d51066e4b0d73d234e4234" offset:_start limit:EACH_FECTH_COUNT type:FeedListTypeUserOpus delegate:self];
    [[FeedService defaultService] getUserOpusList:[[UserManager defaultManager]  userId] offset:_start limit:EACH_FECTH_COUNT type:FeedListTypeUserOpus delegate:self];

    
    [ProtocolUtil createFramesTestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSelectedOpusesHolderView:nil];
    [self setComfirmBtn:nil];
    [super viewDidUnload];
}

- (void)hideComfirmButton
{
    self.comfirmBtn.hidden = YES;
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
    int count = ([dataList count] / MAX_OPUSES_EACH_CELL) + ([dataList count] % MAX_OPUSES_EACH_CELL == 0 ? 0 : 1);
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpusCell *cell = [tableView dequeueReusableCellWithIdentifier:[OpusCell getCellIdentifier]];
    if (cell == nil) {
        cell = [OpusCell createCell:self];
        cell.delegate = self;
    }

    NSRange range = NSMakeRange(indexPath.row * MAX_OPUSES_EACH_CELL, MIN(MAX_OPUSES_EACH_CELL, [dataList count] - indexPath.row * MAX_OPUSES_EACH_CELL));

    [cell setCellData:[dataList subarrayWithRange:range]];
    
    return cell;
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)updateSelectedOpusesView
{
    [self.selectedOpusesHolderView removeAllSubviews];
    
    for (int index=0; index<[_opuses count]; index++) {
        
        CGRect rect = CGRectMake(index * OPUS_VIEW_WIDTH, 0, OPUS_VIEW_WIDTH, OPUS_VIEW_HEIGHT);
        UIImageView *opusView  = [[[UIImageView alloc] initWithFrame:rect] autorelease];
        [opusView setImageWithURL:[NSURL URLWithString:[[_opuses objectAtIndex:index] drawImageUrl]]];
        [self.selectedOpusesHolderView addSubview:opusView];
    }
}

- (void)didClickOpus:(DrawFeed *)opus
{
    PPDebug(@"didClickOpus:%@", opus.wordText);

    if ([_opuses indexOfObject:opus] == NSNotFound) {
        [_opuses addObject:opus];
    }else{
        [_opuses removeObject:opus];
    }
    
    if ([_delegate respondsToSelector:@selector(didController:clickOpus:)]) {
        [_delegate didController:self clickOpus:opus];
    }
    
    [self updateSelectedOpusesView];
}

- (IBAction)clickCreateWallButton:(id)sender {
    if ([_opuses count] < 4) {
        [self popupMessage:@"请选够四张作品！" title:@"作品数不够"];
        return;
    }
    
    Wall *wall = [[[Wall alloc] initWithName:@"我的画墙" layout:[ProtocolUtil createTestData] opuses:_opuses musicUrl:nil] autorelease];
    OpusWallController *vc = [[[OpusWallController alloc] initWithWall:wall] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
