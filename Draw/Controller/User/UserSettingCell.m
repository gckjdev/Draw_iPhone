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
    
    /*
    ShareImageManager* imgManager = [ShareImageManager defaultManager];
    if (rowCount == 1) {
        [self.backgroundImageView setImage:[imgManager settingCellOneBgImage]];
        return;
    }
    if (row == 0) {
        [self.backgroundImageView setImage:[imgManager settingCellTopBgImage]];
        [self.customAccessory setCenter:CGPointMake(self.customAccessory.center.x, self.bounds.size.height/2 + Y_OFFSET)];
        [self.customTextLabel setCenter:CGPointMake(self.customTextLabel.center.x, self.bounds.size.height/2 + Y_OFFSET)];
        [self.customDetailLabel setCenter:CGPointMake(self.customDetailLabel.center.x, self.bounds.size.height/2 + Y_OFFSET)];
        return;
    } else if (row == rowCount-1) {
        [self.backgroundImageView setImage:[imgManager settingCellBottomBgImage]];
        [self.customAccessory setCenter:CGPointMake(self.customAccessory.center.x, self.bounds.size.height/2 - Y_OFFSET)];
        [self.customTextLabel setCenter:CGPointMake(self.customTextLabel.center.x, self.bounds.size.height/2 - Y_OFFSET)];
        [self.customDetailLabel setCenter:CGPointMake(self.customDetailLabel.center.x, self.bounds.size.height/2 - Y_OFFSET)];
//        [self.customSeparatorLine setHidden:YES];
        return;
    } else {
        [self.backgroundImageView setImage:[imgManager settingCellMiddleBgImage]];
        return;
    }
    */
    
    
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    if (selected) {
//        [self.backgroundImageView setBackgroundColor:[UIColor blueColor]];
//    } else {
//        [self.backgroundImageView setBackgroundColor:[UIColor clearColor]];
//    }
//}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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
