//
//  CommonOpusDetailController.m
//  Draw
//
//  Created by 王 小涛 on 13-5-31.
//
//


#define SPACE_CELL_MIN_COUNT 7

enum{
    SectionUserInfo = 0,
    SectionOpusInfo,
//    SectionActionInfo,
    SectionNumber
};


#import "CommonOpusDetailController.h"

@interface CommonOpusDetailController ()


@end

@implementation CommonOpusDetailController

- (void)dealloc {
    [_titleLabel release];
    [_pbOpus release];
    [_userInfoCell release];
    [_opusInfoCell release];
    [_actionHeader release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionUserInfo:
        case SectionOpusInfo:
            return 1;
//        case SectionActionInfo:
//            return [self.dataList count];
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
//    return (section == SectionActionInfo) ? [self heightForActionHeader] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
            
        case SectionUserInfo:
            return [self heightForUserInfoCell];
            
        case SectionOpusInfo:
            return [self heightForOpusInfoCell];
            
//        case SectionActionInfo:
//            return [self heightForCommentInfoCellAtRow:indexPath.row];
            
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    if(section == SectionActionInfo){
//        return [self headerForAction];
//    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionUserInfo:
        {
            return [self cellForUserInfo];
        }
        case SectionOpusInfo:
        {
            return [self cellForOpusInfo];
        }
//        case SectionActionInfo:
//        {
//            return [self cellForCommentInfoAtRow:indexPath.row];
//        }
        default:
            return nil;
    }
}

- (UIView *)headerForAction{
    CommonActionHeader *header = [self.dataTableView dequeueReusableHeaderFooterViewWithIdentifier:[[_actionHeader class] getHeaderIdentifier]];
    
    if (header == nil) {
        header = [[_actionHeader class] createHeader:self];
    }
    
    // TODO: set info for header here.
    
    return header;
}

- (UITableViewCell *)cellForUserInfo{
    
    CommonUserInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_userInfoCell class] getCellIdentifier]];

    if (cell == nil) {
        cell = [[_userInfoCell class] createCell:self];
    }
    
    [cell setUserInfo:_pbOpus.author];
    
    return cell;
}

- (UITableViewCell *)cellForOpusInfo{
    CommonOpusInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_opusInfoCell class] getCellIdentifier]];
    
    if (cell == nil) {
        cell = [[_opusInfoCell class] createCell:self];
    }
    
    [cell setOpusInfo:_pbOpus];
    
    return cell;
}

- (UITableViewCell *)cellForCommentInfoAtRow:(int)row{
    return nil;
}

- (CGFloat)heightForActionHeader{
    return [[_actionHeader class] getHeaderHeight];
}

- (CGFloat)heightForUserInfoCell{
    return [[_userInfoCell class] getCellHeight];
}

- (CGFloat)heightForOpusInfoCell{
    return [[_opusInfoCell class] getCellHeightWithOpus:_pbOpus];
}

- (CGFloat)heightForCommentInfoCellAtRow:(int)row{
    return 0;
}

- (void)didClickOpusImageButton:(PBOpus *)opus{
    [self clickOnOpus:(PBOpus *)opus];
}

- (void)didClickTargetUserButton:(PBGameUser *)user{
    [self clickOnTargetUser:user];
}

- (void)didClickActionButton:(UIButton *)sender{
    [self clickAction:sender];
}

- (void)clickOnOpus:(PBOpus *)opus{
}

- (void)clickOnTargetUser:(PBGameUser *)user{
}

- (void)clickAction:(id)sender{
}

@end
