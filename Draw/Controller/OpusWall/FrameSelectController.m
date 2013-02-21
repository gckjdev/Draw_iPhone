//
//  FrameSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-28.
//
//

#import "FrameSelectController.h"
#import "FrameCell.h"
#import "FrameManager.h"

@interface FrameSelectController ()

@end

@implementation FrameSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataList = [[FrameManager sharedFrameManager] frames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FrameCell getCellHeight];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = ([dataList count] / MAX_FRAMES_EACH_CELL) + ([dataList count] % MAX_FRAMES_EACH_CELL == 0 ? 0 : 1);

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCell *cell = [tableView dequeueReusableCellWithIdentifier:[FrameCell getCellIdentifier]];
    if (cell == nil) {
        cell = [FrameCell createCell:self];
    }
    
    NSRange range = NSMakeRange(indexPath.row * MAX_FRAMES_EACH_CELL, MIN(MAX_FRAMES_EACH_CELL, [dataList count] - indexPath.row * MAX_FRAMES_EACH_CELL));
    
    [cell setCellData:[dataList subarrayWithRange:range]];
    
    return cell;
}
- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickFrame:(PBFrame *)frame
{
    PPDebug(@"didClickFrame: %d", frame.frameId);
    if ([_delegate respondsToSelector:@selector(didController:clickFrame:)]) {
        [_delegate didController:self clickFrame:frame];
    }
}


@end
