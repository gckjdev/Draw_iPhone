//
//  DiceHelpView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceHelpView.h"

@interface DiceHelpView ()

@end

@implementation DiceHelpView

// just replace PPTableViewCell by the new Cell Class Name
+ (id)createDiceHelpView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceHelpView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];;
}

- (IBAction)clickCloseButton:(id)sender {
        [self removeFromSuperview];
}

@end
