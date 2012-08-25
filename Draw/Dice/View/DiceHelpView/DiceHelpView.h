//
//  DiceHelpView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontButton.h"


typedef enum {
	AnimationTypeCaseInCaseOut = 0,
	AnimationTypeUpToDown = 1,
    AnimationTypeLeftToRight =2,
} AnimationType;


@protocol DiceHelpViewDelegate <NSObject>

@required
- (void)didHelpViewHide;

@end

@interface DiceHelpView : UIView <UIWebViewDelegate>

@property (assign, nonatomic) id<DiceHelpViewDelegate> delegate;

+ (id)createDiceHelpView;

- (void)showInView:(UIView *)view;

//- (void)showInView:(UIView *)view animationType:(AnimationType)animationType;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet FontButton *gameRulesButton;
@property (retain, nonatomic) IBOutlet FontButton *itemsUsageButton;

@end
