//
//  DicePopupViewManager.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"
#import "ToolSheetView.h"

@interface DicePopupViewManager : NSObject

+ (id)defaultManager;

- (void)popupCallDiceViewWithDice:(int)dice
                            count:(int)count
                           atView:(UIView *)atView
                           inView:(UIView *)inView
                   pointDirection:(PointDirection)pointDirection;

- (void)dismissCallDiceView;

- (void)popupToolSheetViewWithTitleList:(NSArray *)titleList 
                        countNumberList:(NSArray *)countNumberList 
                               delegate:(id<ToolSheetViewDelegate>)delegate 
                                 atView:(UIView *)atView 
                                 inView:(UIView *)inView;

- (void)dismissToolSheetView;   


- (void)popupMessage:(NSString *)message
              atView:(UIView *)atView
              inView:(UIView *)inView
      pointDirection:(PointDirection)pointDirection;

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
//                             duration:(int)duration
                       pointDirection:(PointDirection)pointDirection;

- (void)dismissOpenDiceView;


@end
