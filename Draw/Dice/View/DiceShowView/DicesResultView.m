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
#import "DeviceDetection.h"


#define TAG_BOTTOM      1
#define TAG_START_DICE  10

#define FRAME_SELF      (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 48, 48) : CGRectMake(0, 0, 96, 96))
#define FRAME_BOTTOM    (([DeviceDetection isIPAD]) ? CGRectMake(0, 12, 48, 36) : CGRectMake(0, 24, 96, 72))  

#define WIDTH_DICE      (([DeviceDetection isIPAD]) ? 17 : 34 )
#define HEIGHT_DICE     (([DeviceDetection isIPAD]) ? 20 : 40 )
#define FRAME_DICE_1    (([DeviceDetection isIPAD]) ? CGRectMake(16, 5, WIDTH_DICE, WIDTH_DICE) : CGRectMake(32, 10, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_2    (([DeviceDetection isIPAD]) ? CGRectMake(4, 12, WIDTH_DICE, WIDTH_DICE) : CGRectMake(8, 24, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_3    (([DeviceDetection isIPAD]) ? CGRectMake(28, 11, WIDTH_DICE, WIDTH_DICE) : CGRectMake(52, 22, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_4    (([DeviceDetection isIPAD]) ? CGRectMake(9, 24, WIDTH_DICE, WIDTH_DICE) : CGRectMake(18, 48, WIDTH_DICE, WIDTH_DICE) )
#define FRAME_DICE_5    (([DeviceDetection isIPAD]) ? CGRectMake(24, 24, WIDTH_DICE, WIDTH_DICE) : CGRectMake(48, 48, WIDTH_DICE, WIDTH_DICE) )

@implementation DicesResultView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.frame = FRAME_SELF;
        UIImageView *bottomView = [[UIImageView alloc] initWithFrame:FRAME_BOTTOM];
        bottomView.tag = TAG_BOTTOM;
        [self addSubview:bottomView];
        [bottomView release];
        
        for (int index = 0; index < 5; index++) {
            CGRect diceFrame;
            
            switch (index) {
                case 0:
                    diceFrame = FRAME_DICE_1;
                    break;
                case 1:
                    diceFrame = FRAME_DICE_2;
                    break;
                case 2:
                    diceFrame = FRAME_DICE_3;
                    break;
                case 3:
                    diceFrame = FRAME_DICE_4;
                    break;
                case 4:
                    diceFrame = FRAME_DICE_5;
                    break;
                default:
                    break;
            }
            
            UIImageView *diceView = [[UIImageView alloc] initWithFrame:diceFrame];
            diceView.tag = TAG_START_DICE + index;
            [self addSubview:diceView];
            [diceView release];
        }
    }
    return self;
}

- (void)setDices:(NSArray *)diceList
{
    [self clearDices];
    
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

- (void)clearDices
{    
    UIImageView *bottomImageView = (UIImageView*)[self viewWithTag:TAG_BOTTOM];
    [bottomImageView setImage:nil];
    
    for (int index = 0; index < 6 ; index ++) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:TAG_START_DICE + index];
        [imageView setImage:nil];
    }
}

@end
