//
//  HelpView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontButton.h"


#define DICE_HELP_VIEW_TAG      2012090488

typedef enum {
    AnimationTypeNone = 0,
	AnimationTypeCaseInCaseOut = 1,
	AnimationTypeUpToDown = 2,
    AnimationTypeLeftToRight =3,
} AnimationType;


@protocol HelpViewDelegate <NSObject>

@required
- (void)didHelpViewHide;

@end

@interface HelpView : UIView <UIWebViewDelegate>

@property (assign, nonatomic) id<HelpViewDelegate> delegate;

+ (id)createHelpView:(NSString *)nibName;

- (void)showInView:(UIView *)view;

//- (void)showInView:(UIView *)view animationType:(AnimationType)animationType;
@property (retain, nonatomic) IBOutlet FontButton *closeButton;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) IBOutlet FontButton *gameRulesButton;
@property (retain, nonatomic) IBOutlet FontButton *itemsUsageButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
