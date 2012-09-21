//
//  DiceView.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"
#import "CustomDiceManager.h"

@interface DiceView : UIButton

@property (retain, nonatomic) UIImageView *seletedBgImageView;

- (id)initWithFrame:(CGRect)frame 
             pbDice:(PBDice *)pbDice 
     customDiceType:(CustomDiceType)type;

- (id)initWithFrame:(CGRect)frame 
               dice:(int)dice 
     customDiceType:(CustomDiceType)type;

- (id)initWithFrame:(CGRect)frame 
             pbDice:(PBDice *)pbDice;

- (id)initWithFrame:(CGRect)frame 
               dice:(int)dice;

- (void)setPBDice:(PBDice *)dice;

- (void)setDice:(int)dice;
- (int)dice;
- (int)diceId;

@end
