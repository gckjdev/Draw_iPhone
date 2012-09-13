//
//  DicePopupViewManager.h
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dice.pb.h"
#import "DiceItemListView.h"
#import "ChatView.h"

@interface DicePopupViewManager : NSObject

//+ (id)defaultManager;

- (void)popupCallDiceViewWithDice:(int)dice
                            count:(int)count
                           atView:(UIView *)atView
                           inView:(UIView *)inView
                     aboveSubView:(UIView *)siblingSubview
                   pointDirection:(PointDirection)pointDirection;

- (void)dismissCallDiceView;

- (void)popupItemListAtView:(UIView *)atView 
                     inView:(UIView *)inView
               aboveSubView:(UIView *)siblingSubview
                   duration:(int)duration
                   delegate:(id<DiceItemListViewDelegate>)delegate;

- (void)updateItemListView;
- (void)dismissItemListView;   


- (void)popupMessage:(NSString *)message
              atView:(UIView *)atView
              inView:(UIView *)inView
        aboveSubView:(UIView *)siblingSubview
      pointDirection:(PointDirection)pointDirection;

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
                         aboveSubView:(UIView *)siblingSubview
                       pointDirection:(PointDirection)pointDirection;

- (void)dismissOpenDiceView;

- (void)popupChatViewAtView:(UIView *)atView
                     inView:(UIView *)inView
               aboveSubView:(UIView *)siblingSubview
                  deleagate:(id<ChatViewDelegate>)delegate;

- (void)dismissChatView;


@end
