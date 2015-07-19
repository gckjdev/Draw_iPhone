//
//  EditTagCell.m
//  Draw
//
//  Created by Kira on 13-6-14.
//
//

#import "EditTagCell.h"
#import "TagPackage.h"
#import "AutoCreateViewByXib.h"

@implementation EditTagCell
AUTO_CREATE_VIEW_BY_XIB(EditTagCell)


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define BTN_TAG 20130608

+ (CGFloat)getCellHeight
{
    return ISIPAD?190:98;
}

+ (NSString*)getCellIdentifier
{
    return @"EditTagCell";
}

+ (EditTagCell*)createCell:(id)delegate
{
    EditTagCell *cell = [EditTagCell createView];
    
    for (int i = BTN_TAG; i < (BTN_TAG+6); i++) {
        UIButton *btn = (UIButton *)[cell viewWithTag:i];
        SET_VIEW_ROUND_CORNER(btn);
        [btn setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:UIControlStateNormal];
        [btn setBackgroundImage:IMAGE_FROM_COLOR(COLOR_ORANGE) forState:UIControlStateSelected];
        
        [btn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [btn setTitleColor:COLOR_WHITE forState:UIControlStateSelected];

    }
    return cell;
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
