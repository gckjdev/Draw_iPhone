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
#import "GroupModelExt.h"
#import "UILabel+Extend.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "GroupPermission.h"
#import "ChangeAvatar.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+BGImage.h"
#import "GroupConstants.h"


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
    RowMemberStart
}MemberSectionRow;

#define TITLE_USER_DETAIL NSLS(@"kUserDetail")
#define TITLE_RM_ADMIN NSLS(@"kRemoveAdmin")
#define TITLE_CHANGE_TITLE NSLS(@"kChangeTitle")
#define TITLE_RM_MEMBER NSLS(@"kRemoveMember")
#define TITLE_SET_ADMIN NSLS(@"kSetAsAdmin")


#define TITLE_ADD_TITLE NSLS(@"kAddTitle")
#define TITLE_CHANGE_BG NSLS(@"kChangeBG")
#define TITLE_UPGRADE NSLS(@"kUpgradeGroup")
#define TITLE_QUIT_GROUP NSLS(@"kQuitGroup")
#define TITLE_DISMISSAL NSLS(@"kDissolveGroup")


#define SIGN_LABEL_HEIGHT (ISIPAD? 490 : 238)
#define MIN_SIGN_HEIGHT (ISIPAD?35:21)
#define TABLE_SIGN_SPACE (ISIPAD? 15 : 6)

@interface GroupDetailController ()
{
    GroupService *groupService;
    GroupManager *groupManager;
    
    
    PBGroupTitle *invitingTitle;
    
}
@property(nonatomic, retain) PBGroup *group;
@property(nonatomic, retain) NSMutableArray *members;
@property(nonatomic, retain) GroupPermissionManager *groupPermission;

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet GroupIconView *groupIconView;
@property (retain, nonatomic) IBOutlet UILabel *groupName;
@property (retain, nonatomic) IBOutlet UILabel *groupSignature;
@property (retain, nonatomic) ChangeAvatar *changeImage;
@property (assign, nonatomic) UIImageView *bgImageView;


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
    PPRelease(_groupPermission);
    PPRelease(_changeImage);
        
    [super dealloc];
}


- (void)clickJoin:(id)sender
{
    [self showActivityWithText:NSLS(@"kJoiningGroup")];
    [groupService joinGroup:_group.groupId message:nil callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            POSTMSG(NSLS(@"kSentRequest"));
            _titleView.rightButton.hidden = YES;
        }
    }];
}

- (void)quit
{
    
    [self showActivityWithText:NSLS(@"kQuitingGroup")];
    [groupService quitGroup:_group.groupId callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            POSTMSG(NSLS(@"kQuitedGroup"));
            [GroupManager didUserQuited:[[UserManager defaultManager] pbUser]];
            [GroupPermissionManager removeRole:_group.groupId];
            [self reloadView];
        }
    }];
}

- (void)clickQuit:(id)sender
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGroupTitle") message:NSLS(@"kQuitGroupMessage") style:CommonDialogStyleSingleButton];
    [dialog setClickOkBlock:^(id infoView){
        [self quit];
        [dialog setClickOkBlock:NULL];
    }];
    [dialog showInView:self.view];
}


- (void)showAddTitleView{
    CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kCreateTitle")];
    dialog.inputTextField.text = @"";
    NSString *groupId = _group.groupId;
    [dialog setClickOkBlock:^(id infoView){
        NSString *text = dialog.inputTextView.text;
        BOOL flag = [self checkText:text length:MAX_LENGTH_TITLE allowEmpty:NO];
        [dialog setManualClose:!flag];
        if (flag) {
            NSInteger titleId = [GroupManager genTitleId];
            [self showActivityWithText:NSLS(@"kCreatingTitle")];
            [groupService createGroupTitle:text titleId:titleId groupId:groupId callback:^(NSError *error) {
                [self hideActivity];
                if (!error) {
                    [self.dataTableView reloadData];
                }
            }];
        }
    }];
    [dialog showInView:self.view];

}

- (void)upgradeGroup:(NSInteger)level
{    
    //TODO check the balance.
    
    [self showActivityWithText:NSLS(@"kUpgradingGroup")];
    [groupService upgradeGroup:_group.groupId level:level callback:^(NSError *error) {
        [self hideActivity];
        if (!error) {
            [self reloadView];
        }
    }];

}

- (void)showUpgradeGroupView
{
    CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kUpgradeGroupTitle")];
    dialog.inputTextField.textColor = COLOR_BROWN;
    dialog.allowInputEmpty = NO;
    dialog.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    dialog.inputTextField.text = [@(_group.level+1) stringValue];
    [dialog setClickOkBlock:^(id view) {
        NSString *text = [dialog.inputTextField text];
        NSInteger level = [text integerValue];
        if (level <= [_group level]) {
            POSTMSG(NSLS(@"kDegradeGroup"));
            [dialog setManualClose:YES];
        }else{
            [self upgradeGroup:level];
            [dialog setManualClose:NO];
        }
    }];
    [dialog showInView:self.view];
    
}

- (void)clickManage:(id)sender
{
    NSMutableArray *titles = [NSMutableArray array];
    [titles addObject:TITLE_ADD_TITLE];
    [titles addObject:TITLE_CHANGE_BG];
    
    if ([_groupPermission canUpgradeGroup]) {
        [titles addObject:TITLE_UPGRADE];
    }
    if ([_groupPermission canQuitGroup]) {
        [titles addObject:TITLE_QUIT_GROUP];
    }
//    if ([_groupPermission canDismissalGroup]) {
//        [titles addObject:TITLE_DISMISSAL];
//    }

    BBSActionSheet* sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
        NSString *title = titles[index];
        if ([title isEqualToString:TITLE_CHANGE_BG]) {
            [self showChangeBGView];            
        }else if([title isEqualToString:TITLE_ADD_TITLE]){
            [self showAddTitleView];
        }else if([title isEqualToString:TITLE_QUIT_GROUP]){
            [self clickQuit:self.titleView.rightButton];
        }else if([title isEqualToString:TITLE_DISMISSAL]){
            //TODO dismissal            
        }else if ([title isEqualToString:TITLE_UPGRADE]){
            [self showUpgradeGroupView];
        }
    }];
    [sheet showInView:self.view showAtPoint:self.view.center animated:YES];
    [sheet release];
    return;
    
}

- (void)showChangeIconView
{
    if (![GroupManager isMeAdminOrCreatorInSharedGroup]) {
        return;
    }

    __block GroupDetailController *cp = self;
    
    [self.changeImage showSelectionView:(id)self selectedImageBlock:^(UIImage *image) {
        [cp showActivityWithText:NSLS(@"kUpdating")];
        [groupService updateGroup:cp.group.groupId icon:image callback:^(NSURL *url, NSError *error) {
            [cp hideActivity];
            if (!error) {
                [cp.groupIconView setImageURL:url];
                PBGroup *group = [GroupManager updateGroup:cp.group medalImageURL:[url absoluteString]];
                [cp updateGroup:group];
            }
        }];
    } didSetDefaultBlock:NULL title:NSLS(@"kChangeGroupIcon") hasRemoveOption:NO];

}

- (void)showChangeBGView
{
    if (![GroupManager isMeAdminOrCreatorInSharedGroup]) {
        return;
    }

    __block GroupDetailController *cp = self;
    [self.changeImage showSelectionView:(id)self selectedImageBlock:^(UIImage *image) {
        [self showActivityWithText:NSLS(@"kUpdating")];
        [groupService updateGroup:cp.group.groupId BGImage:image callback:^(NSURL *url, NSError *error) {
            [cp hideActivity];
            if (!error) {
                [cp.bgImageView setImageWithURL:url];
                PBGroup *group = [GroupManager updateGroup:cp.group BGImageURL:[url absoluteString]];
                [cp updateGroup:group];
            }
        }];
        
    } didSetDefaultBlock:NULL title:NSLS(@"kChangeGroupBG") hasRemoveOption:NO];
}

- (void)updateRightButton
{
    if ([_groupPermission canManageGroup]) {
        [self.titleView setRightButtonTitle:NSLS(@"kManage")];
        [self.titleView setRightButtonSelector:@selector(clickManage:)];
    }else if ([_groupPermission canJoinGroup]){
        [self.titleView setRightButtonTitle:NSLS(@"kJoinGroup")];
        [self.titleView setRightButtonSelector:@selector(clickJoin:)];
    }else if([_groupPermission canQuitGroup]){
        [self.titleView setRightButtonTitle:NSLS(@"kQuitGroup")];
        [self.titleView setRightButtonSelector:@selector(clickQuit:)];
    }else{
        
    }
}

- (void)initViews
{
    [self setDefaultBGImage];
    //update title view
    [self.titleView setTarget:self];
    [self.titleView setTitle:_group.name];
    [self updateRightButton];
    
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setTransparentStyle];

    //update header.
    [self.groupName setTextColor:COLOR_ORANGE];
    [self.groupSignature setTextColor:COLOR_BROWN];
    [self.groupName setFont:CELL_NICK_FONT];
    [self.groupSignature setFont:CELL_CONTENT_FONT];
    [self.groupSignature setLineBreakMode:NSLineBreakByCharWrapping];
    [self.groupSignature setNumberOfLines:0];
    
    [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.changeImage = [[[ChangeAvatar alloc] init] autorelease];
    self.changeImage.autoRoundRect = NO;
    
    //update bg image view.
    self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.bgImageView.autoresizingMask = (0x1 << 6) -1;
    [self.view insertSubview:self.bgImageView atIndex:0];
    [self.bgImageView release];
    [self.bgImageView setImageWithURL:_group.bgImageURL];
    
    
    __block GroupDetailController *cp = self;
    [self.groupIconView setClickHandler:^(IconView *iconView){
        [cp showChangeIconView];
    }];

    
}



- (void)reloadView
{
    //update group info
    [self updateRightButton];
    
    [self.groupIconView setGroupId:_group.groupId];
    [self.groupIconView setImageURL:[_group medalImageURL]
                   placeholderImage:[[ShareImageManager defaultManager] unloadBg]];

    
    [self.groupName setText:_group.name];
    if ([_group.signature length] == 0) {
        [self.groupSignature setText:NSLS(@"kDefaultGroupSignature")];
    }else{
        [self.groupSignature setText:_group.signature];
    }
    CGRect frame = [self.groupSignature autoFitFrame];
    CGFloat labelHeight = MAX(CGRectGetHeight(frame), MIN_SIGN_HEIGHT);
    
    CGFloat originY = CGRectGetMinY(frame) + labelHeight + TABLE_SIGN_SPACE;
    
    [self.dataTableView updateOriginY:originY];
    CGFloat height = CGRectGetHeight(self.view.bounds) - originY;    
    [self.dataTableView updateHeight:height];
    [self updateDataList];
    [self.dataTableView reloadData];
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

- (void)loadGroupDetail
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [groupService getGroup:_group.groupId callback:^(PBGroup *group, NSError *error) {
        [self hideActivity];
        if (!error) {            
            [self updateGroup:group];
            [self.dataTableView reloadData];
        }
    }];
}

- (void)updateDataList
{
    if ([self.groupPermission canManageGroup]) {
        self.dataList = [groupManager tempMemberList];
    }else{
        self.dataList = [groupManager membersForShow];
    }
}

- (void)loadGroupMembers
{
    [groupService getAllUsersByTitle:_group.groupId callback:^(NSArray *list, NSError *error) {
        if (!error) {
            [groupManager setTempMemberList:[NSMutableArray arrayWithArray:list]];
            [self updateDataList];
            [self.dataTableView reloadData];
        }
    }];
}


- (BOOL)checkText:(NSString *)text
           length:(NSInteger)maxLength
       allowEmpty:(BOOL)allowEmpty
{
    if ([text length] > maxLength) {
        NSString *alertString = [NSString stringWithFormat:NSLS(@"kOutOfMaxLength"), maxLength];
        POSTMSG(alertString);
        return NO;
    }
    if (!allowEmpty && [text length] == 0) {
        POSTMSG(NSLS(@"kTextCanotBeNil"));
        return NO;
    }
    return YES;
}

- (void)alertToEditInfo:(NSString *)title
                   info:(NSString *)info
                    key:(NSString*)key
{
    CommonDialog *dialog = nil;
    BOOL useInputField  = YES;
    NSArray *longInputFields = @[PARA_DESC, PARA_SIGNATURE];
    if ([longInputFields containsObject:key]) {
        dialog = [CommonDialog createInputViewDialogWith:title];
        dialog.inputTextView.text = info;
        useInputField = NO;
    }else{
        dialog = [CommonDialog createInputFieldDialogWith:title];
        dialog.inputTextField.text = info;
    }
    
    NSArray *allowEmptyKeys = @[PARA_SIGNATURE, PARA_DESC];
    BOOL allowEmpty = [allowEmptyKeys containsObject:key];
    [dialog setAllowInputEmpty:allowEmpty];
    NSInteger length = 10;
    if ([key isEqualToString:PARA_FEE]) {
        dialog.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    }else{
        NSDictionary *lenDict = @{PARA_NAME: @(MAX_LENGTH_NAME),
                                  PARA_SIGNATURE: @(MAX_LENGTH_SIGNATURE),
                                  PARA_DESC: @(MAX_LENGTH_DESCRIPTION),
                                  };        
        NSNumber *len = lenDict[key];
        if (len == nil && ![PARA_FEE isEqualToString:key]) {
            return;
        }
        length = [len intValue];
    }

    [dialog setClickOkBlock:^(id infoView){
        NSString *text = dialog.inputTextView.text;
        if (useInputField) {
            text = dialog.inputTextField.text;
        }
        BOOL flag = [self checkText:text length:length allowEmpty:allowEmpty];
        [dialog setManualClose:!flag];
        if (flag) {
            if (text && ![text isEqualToString:info]) {
                //changed.
                [self updateRemoteInfo:@{key: text}];
            }
            [dialog setManualClose:NO];
        }
    }];
    [dialog showInView:self.view];    
}

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (![GroupManager isMeAdminOrCreatorInSharedGroup]) {
        return;
    }

    if (tap.view == self.groupName) {
        [self alertToEditInfo:NSLS(@"kEditGroupName") info:_group.name key:PARA_NAME];
    }else if(tap.view == self.groupSignature){
        [self alertToEditInfo:NSLS(@"kEditGroupSignature") info:_group.signature key:PARA_SIGNATURE];
    }

}

- (void)initTapableLabels
{
    [self.groupName enableTapTouch:self selector:@selector(onTap:)];
    [self.groupSignature enableTapTouch:self selector:@selector(onTap:)];
}

- (void)updateGroup:(PBGroup *)group
{
    self.group = group;
    [[GroupManager defaultManager] setSharedGroup:group];
}

- (void)updatePermissionManager
{
    self.groupPermission = [GroupPermissionManager myManagerWithGroupId:_group.groupId];
}

- (void)viewDidLoad
{
    [groupManager setSharedGroup:self.group];
    [self updatePermissionManager];
    [super viewDidLoad];
    [self initViews];
    [self initTapableLabels];
    [self reloadView];
    [self loadGroupDetail];
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
    [self setGroupSignature:nil];
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
    NSInteger count = [self.dataList count] + RowMemberStart;
    if ([[_group guestsList] count] != 0 || [_groupPermission canManageGroup]) {
        count ++;
    }
    return count;
}

- (BOOL)isFirstRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0);
}

- (BOOL)isLastRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self.dataTableView numberOfRowsInSection:indexPath.section];
    return (indexPath.row == count - 1);
}

- (CellRowPosition)positionForIndexPath:(NSIndexPath *)indexPath
{
    if ([self isFirstRowAtIndexPath:indexPath]) {
        return CellRowPositionFirst;
    }
    if ([self isLastRowAtIndexPath:indexPath]) {
        return CellRowPositionLast;
    }
    return CellRowPositionMid;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[[UIView alloc] init] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (SECTION_BASE_INDEX == indexPath.section) {
        if (row == RowDescription) {
            return [GroupDetailCell getCellHeightForText:[self descCellText]];
        }
        return [GroupDetailCell getCellHeightForSingleLineText];
        
    }else {
        PBGroupUsersByTitle *usersByTitle = nil;
        if (row == RowCreator) {
            return [GroupDetailCell getCellHeightForSingleAvatar];
        }else if(row == RowAdmins){
            usersByTitle = _group.adminsByTitle;
        }else{
            NSInteger index  = row - RowMemberStart;
            if (index == [self.dataList count]) {
                usersByTitle = [_group guestsByTitle];
            }else{
                usersByTitle = self.dataList[index];
            }
        }
        return [GroupDetailCell getCellHeightForUsersByTitle:usersByTitle];
    }
}

- (NSString *)descCellText
{
   return [NSString stringWithFormat:NSLS(@"kGroupDetailRowDesc"), _group.desc];
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
            text = [self descCellText];
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSInteger row = indexPath.row;
    
    if (indexPath.section == SECTION_BASE_INDEX) {
        [self updateBaseSectionCell:cell inRow:row];
    }else{
        CellRowPosition position = [self positionForIndexPath:indexPath];
        
        if (row == RowCreator) {
            [cell setCellForCreatorInGroup:_group position:position];
        }else if(row == RowAdmins){
            [cell setCellForAdminsInGroup:_group position:position];
        }else{
            NSInteger index = row - RowMemberStart;
            PBGroupUsersByTitle *usersByTitle;
            
            if (index < [self.dataList count]) {
                usersByTitle = self.dataList[index];
            }else if ([self isLastRowAtIndexPath:indexPath]) {
                usersByTitle = [_group guestsByTitle];
            }
            
            [cell setCellForUsersByTitle:usersByTitle position:position inGroup:_group];
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
            [groupManager setSharedGroup:_group];
            [self reloadView];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![GroupManager isMeAdminOrCreatorInSharedGroup]) {
        return;
    }
    if (indexPath.section == SECTION_BASE_INDEX) {

        if (indexPath.row == RowDescription) {
            [self alertToEditInfo:NSLS(@"kEditGroupDesc") info:_group.desc key:PARA_DESC];
        }else if(indexPath.row == RowFee){
            NSString *feeString = [@(_group.memberFee) stringValue];
            [self alertToEditInfo:NSLS(@"kEditGroupFee") info:feeString key:PARA_FEE];
        }else{
            
        }
        
    }
}


- (void)enterUserDetail:(PBGameUser *)user
{
    ViewUserDetail *detail = [ViewUserDetail viewUserDetailWithUser:user];
    [UserDetailViewController presentUserDetail:detail inViewController:self];
}

#pragma mark-- group detail cell delegate.



- (void)groupDetailCell:(GroupDetailCell *)cell
        didClickCreator:(PBGameUser *)user
{
    PPDebug(@"<didClickCreator> uid = %@", user.userId);
    [self enterUserDetail:user];
}



- (void)handleTitle:(NSString *)title user:(PBGameUser *)user groupTitle:(PBGroupTitle *)groupTitle
{
    
    NSInteger titleId = groupTitle.titleId;
    if ([title isEqualToString:TITLE_USER_DETAIL]) {
        [self enterUserDetail:user];
        return;
    }
    else if ([title isEqualToString:TITLE_RM_ADMIN]) {
        [self showActivityWithText:NSLS(@"kRemovingAdmin")];
        [groupService removeUserFromAdmin:user inGroup:_group.groupId callback:^(NSError *error) {
            [self hideActivity];
            if (!error) {
                PBGroup *nGroup = [GroupManager didRemoveUser:user fromAdminInGroup:_group];
                [self updateGroup:nGroup];
                [self.dataTableView reloadData];
            }
        }];
    }
    else if ([title isEqualToString:TITLE_CHANGE_TITLE]) {
        NSArray *ts = [GroupManager candidateTitlesForChangingTitle:groupTitle];
        NSMutableArray *titleNames = [NSMutableArray array];
        for (PBGroupTitle *t in ts) {
            [titleNames addObject:t.title];
        }
        BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titleNames callback:^(NSInteger index) {
            PBGroupTitle *t = ts[index];
            [self showActivityWithText:NSLS(@"kChangingTitle")];
            [groupService changeUser:user inGroup:_group.groupId sourceTitleId:groupTitle.titleId title:t.titleId callback:^(NSError *error) {
                [self hideActivity];
                if (!error) {
                    [self.dataTableView reloadData];
                }
            }];
        }];
        [sheet showInView:self.view showAtPoint:self.view.center animated:YES];
    }
    else if ([title isEqualToString:TITLE_RM_MEMBER]) {
        [self showActivityWithText:NSLS(@"kExpeling")];
        [groupService expelUser:user group:_group.groupId titleId:titleId reason:@"" callback:^(NSError *error) {
            [self hideActivity];
            if (!error) {
                [GroupManager didRemoveUser:user fromTitleId:titleId];                
                [self.dataTableView reloadData];
            }
        }];
    }
    else if ([title isEqualToString:TITLE_SET_ADMIN]) {
        [self showActivityWithText:NSLS(@"kSettingAsAdmin")];
        [groupService setUserAsAdmin:user inGroup:_group.groupId callback:^(NSError *error) {
            [self hideActivity];
            if (!error) {
                PBGroup *nGroup = [GroupManager didSetUser:user asAdminInGroup:_group];
                [self updateGroup:nGroup];
                [self.dataTableView reloadData];
            }
        }];
    }
}

- (NSMutableArray *)titlesForUser:(PBGameUser *)user title:(PBGroupTitle *)title
{
    NSMutableArray *titles = [NSMutableArray arrayWithObject:TITLE_USER_DETAIL];
    if (title.titleId == GroupRoleAdmin) {
        if ([self.groupPermission canArrangeAdmin] && ![user isEqual:_group.creator]) {
            [titles addObject:TITLE_RM_ADMIN];
        }
    }else{
        if ([self.groupPermission canArrangeAdmin]) {
            if ([_group.adminsList containsObject:user]) {
                [titles addObject:TITLE_RM_ADMIN];
            }else{
                [titles addObject:TITLE_SET_ADMIN];
            }
        }
        if ([self.groupPermission canCustomTitle]) {
            [titles addObject:TITLE_CHANGE_TITLE];
        }
        if ([self.groupPermission canExpelUser:user] && ![GroupManager isUser:user adminOrCreatorInGroup:_group]) {
            [titles addObject:TITLE_RM_MEMBER];
        }
    }
    return titles;
}

- (void)groupDetailCell:(GroupDetailCell *)cell
           didClickUser:(PBGameUser *)user
                  title:(PBGroupTitle *)title
{
    PPDebug(@"<didClickUser>title = %@, titleId = %d", title.title, title.titleId);
    
    
    NSMutableArray *titles = [self titlesForUser:user title:title];
    if ([titles count] <= 1) {
        [self enterUserDetail:user];
    }else{
        [titles addObject:NSLS(@"kCancel")];
        BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:titles callback:^(NSInteger index) {
            NSString *t = titles[index];
            [self handleTitle:t user:user groupTitle:title];
        }];
        [sheet showInView:self.view showAtPoint:self.view.center animated:YES];
        [sheet release];
    }
}


- (void)friendController:(FriendController *)controller
         didSelectFriend:(MyFriend *)aFriend
{
    if (invitingTitle == nil || aFriend.friendUserId == nil) {
        return;
    }
    SimpleResultBlock callback = ^(NSError *error){
        [self hideActivity];
        POSTMSG(NSLS(@"kGroupUserInvited"));
        [controller.navigationController popToViewController:self animated:YES];
    };
    
    [self showActivityWithText:NSLS(@"kInviting")];
    if (invitingTitle.titleId == GroupRoleGuest) {
        [groupService inviteGuests:@[aFriend.friendUserId] groupId:_group.groupId callback:callback];
    }else{
        [groupService inviteMembers:@[aFriend.friendUserId] groupId:_group.groupId titleId:invitingTitle.titleId callback:callback];
    }
    invitingTitle = nil;
}


- (void)groupDetailCell:(GroupDetailCell *)cell
didClickAddButtonAtTitle:(PBGroupTitle *)title
{
    PPDebug(@"<didClickAddButtonAtTitle> title = %@, titleId = %d", title.title, title.titleId);
    invitingTitle = title;
    FriendController *fc = [[FriendController alloc] initWithDelegate:self];
    [[self navigationController] pushViewController:fc animated:YES];
    [fc release];

}

- (void)groupDetailCell:(GroupDetailCell *)cell didClickAtTitle:(PBGroupTitle *)title
{
    //check permission
    if ([title titleId] != GroupRoleGuest && [_groupPermission canCustomTitle]) {
        CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kUpdateTitle")];
        dialog.inputTextField.text = title.title;
        [dialog setClickOkBlock:^(id view){
            NSString *text = [dialog.inputTextField text];
            NSInteger len = MAX_LENGTH_TITLE;
            BOOL flag = [self checkText:text length:len allowEmpty:NO];
           [dialog setManualClose:!flag];
            if(flag){
                [groupService updateGroupTitle:_group.groupId titleId:title.titleId title:text callback:^(NSError *error) {
                    if (!error) {
                        [self.dataTableView reloadData];
                    }
                }];
            }
        }];
        [dialog showInView:self.view];
    }else{
        PPDebug(@"<didClickAtTitle> can't custom title.");
    }
}


@end
