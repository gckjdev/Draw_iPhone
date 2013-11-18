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

#define SECTION_NUMBER 2
#define SECTION_BASE_INDEX 0
#define SECTION_MEMBER_INDEX 1


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

@property(nonatomic, retain) PBGroup *group;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet GroupIconView *groupIconView;
@property (retain, nonatomic) IBOutlet UILabel *groupName;
@property (retain, nonatomic) IBOutlet UILabel *groupDesc;

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
    [_groupDesc release];
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

    //update title view
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonTitle:NSLS(@"kEdit")];
    [self.titleView setTransparentStyle];
    
    //update group info
    [self.groupIconView setGroupId:_group.groupId];
    [self.groupIconView setImageURLString:_group.medalImage];
    [self.groupName setText:_group.name];
    [self.groupDesc setText:_group.signature];
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
    [self setGroupDesc:nil];
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
            [cell setCellForMembers:_group.titlesList[indexPath.row] position:position InGroup:_group];
        }
    }
    return cell;
}

@end
