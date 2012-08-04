//
//  OpenDiceView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-4.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKGirlFontLabel.h"

@interface OpenDiceView : HKGirlFontLabel

- (id)initWithOpenType:(int)openType;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
