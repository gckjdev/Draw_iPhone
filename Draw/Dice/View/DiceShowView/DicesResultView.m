//
//  DicesResultView.m
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DicesResultView.h"
#import "PPDebug.h"
#import "DiceImageManager.h"

@implementation DicesResultView
@synthesize userId = _userId;

- (void)dealloc
{
    [_userId release];
    [super dealloc];
}

+ (DicesResultView *)createDicesResultView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DicesResultView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"create <DicesResultView> but cannot find object from Nib");
        return nil;
    }
    DicesResultView* view =  (DicesResultView*)[topLevelObjects objectAtIndex:0];
    
    return view;
}

#define TAB_START_DICE  10
- (void)setDices:(PBUserDice *)userDice
{
    self.userId = userDice.userId;
    
    int index = 0;
    for (PBDice *dice in userDice.dicesList) {
        UIImage *image = [[DiceImageManager defaultManager] openDiceImageWithDice:dice.dice];
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAB_START_DICE + index];
        [imageView setImage:image];
        
        index ++;
        if (index > 5) {
            break;
        }
    }
}

@end
