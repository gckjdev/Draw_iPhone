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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == SectionUserInfo) {
        [self clickOnAuthor:_pbOpus.author];
    }
}

- (UIView *)headerForAction{
    CommonActionHeader *header = [self.dataTableView dequeueReusableHeaderFooterViewWithIdentifier:[[_actionHeaderClass class] getHeaderIdentifier]];
    
    if (header == nil) {
        header = [[_actionHeaderClass class] createHeader:self];
    }
    
    // TODO: set info for header here.
    
    return header;
}

- (UITableViewCell *)cellForUserInfo{
    
    CommonUserInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_userInfoCellClass class] getCellIdentifier]];

    if (cell == nil) {
        cell = [[_userInfoCellClass class] createCell:self];
    }
    
    [cell setUserInfo:_pbOpus.author];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}

- (UITableViewCell *)cellForOpusInfo{
    CommonOpusInfoCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[[_opusInfoCellClass class] getCellIdentifier]];
    
    if (cell == nil) {
        cell = [[_opusInfoCellClass class] createCell:self];
    }
    
    [cell setOpusInfo:_pbOpus];
    
    return cell;
}

- (UITableViewCell *)cellForCommentInfoAtRow:(int)row{
    return nil;
}

- (CGFloat)heightForActionHeader{
    return [[_actionHeaderClass class] getHeaderHeight];
}

- (CGFloat)heightForUserInfoCell{
    return [[_userInfoCellClass class] getCellHeight];
}

- (CGFloat)heightForOpusInfoCell{
    return [[_opusInfoCellClass class] getCellHeightWithOpus:_pbOpus];
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

- (void)clickOnAuthor:(PBGameUser *)author{
    
}

- (void)clickOnOpus:(PBOpus *)opus{
}

- (void)clickOnTargetUser:(PBGameUser *)user{
}

- (void)clickAction:(id)sender{
}

@end
