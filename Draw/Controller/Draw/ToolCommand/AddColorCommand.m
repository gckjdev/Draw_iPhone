//
//  AddColorCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "AddColorCommand.h"

@implementation AddColorCommand

- (void)showPopTipView
{
    
}
- (void)hidePopTipView
{
    
}


//need to be override by the sub classes
- (UIView *)contentView
{
    
}
- (BOOL)excute
{
    if ([super excute]) {
        [self showPopTipView];
    }
}
- (void)finish
{
    
}

@end
