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
#import "StableView.h"

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

#define USER_SETTING_BADGE_VIEW_TAG     2013090501

+ (id)createCell:(id)delegate
{
    UserSettingCell* cell = [UserSettingCell createView];
    
    cell.customDetailLabel.textColor = COLOR_GREEN;
    cell.customTextLabel.textColor = COLOR_BROWN;
    
    BadgeView* badgeView = [BadgeView badgeViewWithNumber:0];
    badgeView.tag = USER_SETTING_BADGE_VIEW_TAG;
    
    [cell.badgeHolderView addSubview:badgeView];
    
//    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
//    cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    return cell;
}

+ (CGFloat)getCellHeight
{
    return ISIPAD?88:44;
}

+ (NSString*)getCellIdentifier
{
    return @"UserSettingCell";
}

#define Y_OFFSET (ISIPAD?12:6)

- (void)setCellWithRow:(NSInteger)row inSectionRowCount:(NSInteger)rowCount
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;            
}

- (void)setBadge:(int)number
{
    BadgeView* badgeView = (BadgeView*)[self.badgeHolderView viewWithTag:USER_SETTING_BADGE_VIEW_TAG];
    [badgeView setNumber:number];    
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
