//
//  DiceGamePlayController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceGamePlayController.h"
#import "DiceImageManager.h"
#import "DicePopupView.h"

@interface DiceGamePlayController ()

@end

@implementation DiceGamePlayController

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark- Buttons action
- (IBAction)clickOpenDiceButton:(id)sender {
    Dice_Builder *diceBuilder = [[[Dice_Builder alloc] init] autorelease];
    [diceBuilder setDice:1];
    [diceBuilder setDiceId:1];
    Dice *dice = [diceBuilder build];
    
    
    [DicePopupView popupCallDiceViewWithDice:dice count:2 atView:(UIView*)sender inView:self.view animated:YES];
    
}

#define TAG_TOOL_BUTTON 12080101
#define TAG_TOOL_SHEET  12080102

- (IBAction)clickToolButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.tag = TAG_TOOL_BUTTON;
    button.selected = !button.selected;
    
    ToolSheetView *toolSheetView = (ToolSheetView *)[self.view viewWithTag:TAG_TOOL_SHEET];
    
    if (toolSheetView == nil) {
        CGPoint fromPoint  = CGPointMake(button.frame.origin.x + 0.5 * button.frame.size.width, button.frame.origin.y );
        NSArray *imageNameList = [NSArray arrayWithObjects:@"tools_bell_bg.png", @"tools_bell_bg.png", @"tools_bell_bg.png",nil];
        NSArray *countNumberList = [NSArray arrayWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5], nil];
                                    
        ToolSheetView *toolSheetView = [[ToolSheetView alloc] initWithImageNameList:imageNameList 
                                                                    countNumberList:countNumberList 
                                                                           delegate:self];
        
        toolSheetView.tag = TAG_TOOL_SHEET;
        [toolSheetView showInView:self.view fromFottomPoint:fromPoint];
        [toolSheetView release];
    } else {
        [toolSheetView removeFromSuperview];
    }
}

- (void)didSelectTool:(NSInteger)index
{
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = !button.selected;
}

@end
