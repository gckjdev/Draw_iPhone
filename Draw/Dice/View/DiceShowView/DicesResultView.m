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
//@synthesize userId = _userId;

- (void)dealloc
{
//    [_userId release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [DicesResultView createDicesResultView];
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

#define TAG_BOTTOM 1
#define TAG_START_DICE  10
- (void)setDices:(NSArray *)diceList
{
    DiceImageManager *imageManage = [DiceImageManager defaultManager];
    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_BOTTOM];
    [bottomImageView setImage:[imageManage diceBottomImage]];
    
    int index = 0;
    for (PBDice *dice in diceList) {
        UIImage *image = nil;
        image = [imageManage openDiceImageWithDice:dice.dice];
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_START_DICE + index];
        [imageView setImage:image];
        
        index ++;
        if (index > 5) {
            break;
        }
    }
}

- (void)clearUserDices
{    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_BOTTOM];
    [bottomImageView setImage:nil];
    
    for (int index = 0; index < 6 ; index ++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_START_DICE + index];
        [imageView setImage:nil];
    }
}

@end
