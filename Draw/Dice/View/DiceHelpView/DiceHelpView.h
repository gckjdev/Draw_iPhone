//
//  DiceHelpView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontButton.h"

@interface DiceHelpView : UIView <UIWebViewDelegate>

+ (id)createDiceHelpView;

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet FontButton *gameRulesButton;
@property (retain, nonatomic) IBOutlet FontButton *itemsUsageButton;

@end
