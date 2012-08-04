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
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated;

- (void)dismissCallDiceViewAnimated:(BOOL)animated;

- (void)popupToolSheetViewWithImageNameList:(NSArray *)imageNameList 
                            countNumberList:(NSArray *)countNumberList 
                                   delegate:(id<ToolSheetViewDelegate>)delegate 
                                     atView:(UIView *)view 
                                     inView:(UIView *)inView  
                                   animated:(BOOL)animated;

- (void)dismissToolSheetViewAnimated:(BOOL)animated;

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
                             animated:(BOOL)animated;

- (void)dismissOpenDiceViewAnimated:(BOOL)animated;

@end
