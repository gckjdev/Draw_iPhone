//
//  ClickController+SGFocusImageFrame.m
//  Draw
//
//  Created by ChaoSo on 14-7-17.
//
//

#import "ClickController+SGFocusImageFrame.h"

@implementation SGFocusImageFrame(ClickController)

-(void)clickPageImage:(UIButton *)sender{
    
    UIButton *btn = sender;
    [[self.bbList objectAtIndex:btn.tag] clickAction:<#(PPViewController *)#>]
}
@end
