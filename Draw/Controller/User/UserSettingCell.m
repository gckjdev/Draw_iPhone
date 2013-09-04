//
//  UserSettingCell.m
//  Draw
//
//  Created by Kira on 13-4-11.
//
//

#import "UserSettingCell.h"
#import "AutoCreateViewByXib.h"
#import "PPTableViewController.h"
#import "ShareImageManager.h"

@implementation UserSettingCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

AUTO_CREATE_VIEW_BY_XIB(UserSettingCell)

+ (id)createCell:(id)delegate
{
    UserSettingCell* cell = [UserSettingCell createView];
//    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
//    cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    return cell;
}

+ (float)getCellHeight
{
    return ISIPAD?88:44;
}

+ (NSString*)getCellIdentifier
{
    return @"UserSettingCell";
}

#define Y_OFFSET (ISIPAD?12:6)

- (void)setCellWithRow:(int)row inSectionRowCount:(int)rowCount
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
}

- (void)dealloc {

    [_customDetailLabel release];
    [_customTextLabel release];
    [_backgroundImageView release];
    [_customSeparatorLine release];
    [_customAccessory release];
    [_badgeHolderView release];
    [super dealloc];
}
@end
