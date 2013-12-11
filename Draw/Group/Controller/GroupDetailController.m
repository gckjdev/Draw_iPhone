//
//  GroupDetailController.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "GroupDetailController.h"
#import "CommonTitleView.h"
#import "IconView.h"
#import "GroupDetailCell.h"
#import "TimeUtils.h"
#import "GroupService.h"
#import "GameNetworkConstants.h"
#import "UILabel+Touchable.h"
#import "CommonDialog.h"


enum{
    SECTION_BASE_INDEX = 0,
    SECTION_MEMBER_INDEX = 1,
    SECTION_NUMBER
};



typedef enum{
    RowWealth = 0,
    RowCreateDate,
    RowDescription,
    RowFee,
    BaseSectionRowCount,
}BaseSectionRow;

typedef enum{
    RowCreator = 0,
    RowAdmins,
}MemberSectionRow;


@interface GroupDetailController ()
{
    GroupService *groupService;
    GroupManager *groupManager;
}
@property(nonatomic, retain) PBGroup *group;
@property(nonatomic, retain) NSMutableArray *members;

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet GroupIconView *groupIconView;
@property (retain, nonatomic) IBOutlet UILabel *groupName;
@property (retain, nonatomic) IBOutlet UILabel *groupSignature;

@end

@implementation GroupDetailController


+ (GroupDetailController *)enterWithGroup:(PBGroup *)group
                           fromController:(PPViewController *)controller
{
    GroupDetailController *gd = [[GroupDetailController alloc] init];
    gd.group = group;
    [controller.navigationController pushViewController:gd animated:YES];
    return [gd autorelease];
}

- (void)dealloc
{
    PPRelease(_group);
    [_titleView release];
    [_groupIconView release];
    [_groupName release];
    [_groupSignature release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        groupService = [GroupService defaultService];
        groupManager = [GroupManager defaultManager];
    }
    return self;
}

- (void)loadGroupMembers
{
    [groupService getAllUsersByTitle:_group.groupId callback:^(NSArray *list, NSError *error) {
        if (!error) {
            [groupManager setTempMemberList:[NSMutableArray arrayWithArray:list]];
            [self.dataTableView reloadData];
        }
    }];
}

- (void)alertToEditInfo:(NSString *)title
                   info:(NSString *)info
                    key:(NSString*)key
{
    CommonDialog *dialog = [CommonDialog createInputViewDialogWith:info];
    dialog.inputTextView.text = info;
    if (key == PARA_FEE) {
        dialog.inputTextView.keyboardType = UIKeyboardTypeNumberPad;
    }
    [dialog setClickOkBlock:^(id infoView){
        NSString *text = dialog.inputTextView.text;
        if (text == nil) {
            //TODO pop up
        }
        if (text && ![text isEqualToString:info]) {
            //changed.
            [self updateRemoteInfo:@{key: text}];
        }
    }];
    [dialog showInView:self.view];    
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (tap.view == self.groupName) {
        [self alertToEditInfo:NSLS(@"kEditGroupName") info:self.groupName.text key:PARA_NAME];
    }else if(tap.view == self.groupSignature){
        [self alertToEditInfo:NSLS(@"kEditGroupSignature") info:self.groupName.text key:PARA_DESC];
    }

}

- (void)initTapableLabels
{
    [self.groupName enableTapTouch:self selector:@selector(onTap:)];
    [self.groupSignature enableTapTouch:self selector:@selector(onTap:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //update title view
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonTitle:NSLS(@"kEdit")];
    [self.titleView setTransparentStyle];
    
    //update group info
    [self.groupIconView setGroupId:_group.groupId];
    [self.groupIconView setImageURLString:_group.medalImage];
    [self.groupName setText:_group.name];
    [self.groupSignature setText:_group.signature];
    [self initTapableLabels];
    [self loadGroupMembers];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [self setGroupIconView:nil];
    [self setGroupName:nil];
    [self setgroupSignature:nil];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (SECTION_BASE_INDEX == section){
        return BaseSectionRowCount;
    }
    return [_group.titlesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SECTION_BASE_INDEX == indexPath.section) {
        return [GroupDetailCell getCellHeightForSimpleText];
    }else{
        if (indexPath.row == RowCreator) {
            return [GroupDetailCell getCellHeightForSingleAvatar];
        }
        PBGroupUsersByTitle *usersByTitle = _group.titlesList[indexPath.row];
        return [GroupDetailCell getCellHeightForMultipleAvatar:usersByTitle.usersList.count];
    }
}

- (void)updateBaseSectionCell:(GroupDetailCell *)cell inRow:(NSInteger)row
{
    NSString * text = nil;
    CellRowPosition position = CellRowPositionMid;
    switch (row) {
        case RowWealth:{
            text = [NSString stringWithFormat:NSLS(@"kGroupDetailRowWeath"), _group.fame, _group.balance, _group.level];
            position = CellRowPositionFirst;
            break;
        }
        case RowCreateDate:{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_group.createDate];
            NSString *dateString = dateToLocaleStringWithFormat(date, DATE_FORMAT);
            text = [NSString stringWithFormat:NSLS(@"kGroupDetailRowCreateDate"), dateString];
            break;
        }
        case RowDescription:{
            text = [NSString stringWithFormat:NSLS(@"kGroupDetailRowDesc"), _group.desc];
            break;
        }
        case RowFee:{
            text = [NSString stringWithFormat:NSLS(@"kGroupDetailRowFee"), _group.memberFee];
            position = CellRowPositionLast;
            break;
        }
        default:
            break;
    }
    [cell setCellText:text position:position group:_group];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [GroupDetailCell getCellIdentifier];
    GroupDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [GroupDetailCell createCell:self];
    }
    NSInteger row = indexPath.row;
    if (indexPath.section == SECTION_BASE_INDEX) {
        [self updateBaseSectionCell:cell inRow:row];
    }else{
        if (RowCreator == row) {
            [cell setCellForCreatorInGroup:_group];
        }else{
            CellRowPosition position = CellRowPositionMid;
            if (row == [_group.titlesList count] - 1) {
                position = CellRowPositionLast;
            }
            PBGroupUsersByTitle *usersByTitle = groupManager.tempMemberList[indexPath.row];
            [cell setCellForMembers:usersByTitle position:position InGroup:_group];
        }
    }
    [cell setNeedsLayout];
    return cell;
}

- (void)updateRemoteInfo:(NSDictionary *)info
{
    [self showActivityWithText:NSLS(@"kUpdating")];
    [groupService editGroup:_group.groupId info:info callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            PBGroup_Builder *builder = [PBGroup builderWithPrototype:self.group];
            if (info[PARA_NAME]) {
                [builder setName:info[PARA_NAME]];
            }
            if (info[PARA_DESC]) {
                [builder setDesc:info[PARA_DESC]];
            }
            if (info[PARA_SIGNATURE]) {
                [builder setSignature:info[PARA_SIGNATURE]];
            }
            if (info[PARA_FEE]) {
                [builder setMemberFee:[info[PARA_FEE] integerValue]];
            }
            self.group = [builder build];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:SECTION_BASE_INDEX];
            [self.dataTableView reloadSections:set
                              withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupDetailCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == SECTION_BASE_INDEX) {
        NSDictionary *info = nil;
        if (indexPath.row == RowDescription) {
            [self alertToEditInfo:NSLS(@"kEditGroupDesc") info:cell.text key:PARA_DESC];
        }else if(indexPath.row == RowFee){
            [self alertToEditInfo:NSLS(@"kEditGroupFee") info:cell.text key:PARA_FEE];
        }else{
            
        }
        
    }
}


@end
