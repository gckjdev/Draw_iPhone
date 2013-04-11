//
//  UserSettingCell.m
//  Draw
//
//  Created by Kira on 13-4-11.
//
//

#import "UserSettingCell.h"
#import "AutoCreateViewByXib.h"

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
    return [UserSettingCell createView];
}

+ (float)getCellHeight
{
    return 20;
}

+ (NSString*)getCellIdentifier
{
    return @"UserSettingCell";
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
