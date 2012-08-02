//
//  DicesResultView.m
//  Draw
//
//  Created by haodong on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DicesResultView.h"
#import "PPDebug.h"
#import "Dice.pb.h"
#import "DiceImageManager.h"

@implementation DicesResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
- (void)setDices:(NSArray *)dices
{
    int index = 0;
    for (PBDice *dice in dices) {
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
