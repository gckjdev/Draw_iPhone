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

+ (float)getCellHeight
{
    return ISIPAD?190:98;
}

+ (NSString*)getCellIdentifier
{
    return @"EditTagCell";
}

+ (EditTagCell*)createCell:(id)delegate
{
    return (EditTagCell*)[EditTagCell createView];
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
