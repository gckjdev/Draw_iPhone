//
//  CommonDiceItemAction.m
//  Draw
//
//  Created by 小涛 王 on 12-9-11.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CommonDiceItemAction.h"
#import "HKGirlFontLabel.h"
#import "DiceGamePlayController.h"
#import "UserManager.h"

@interface CommonDiceItemAction ()
{
    UserManager *_userManager;
}

@property (assign, nonatomic) DiceGamePlayController *controller;
@property (assign, nonatomic) UIView *view;

@end

@implementation CommonDiceItemAction

@synthesize controller = _controller;
@synthesize view = _view;

- (id)initWithController:(DiceGamePlayController *)controller
                    view:(UIView *)view
{
    if (self = [super init]) {
        self.controller = controller;
        self.view = view;
        _userManager = [UserManager defaultManager];
    }
    
    return self;
}

- (void)showNameAnimation:(NSString*)userId
                 itemName:(NSString *)itemName
{
    HKGirlFontLabel *label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70) pointSize:50] autorelease];
    label.text = itemName;
    label.textAlignment = UITextAlignmentCenter;
    label.center = self.view.center;
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        label.center = [[_controller bellViewOfUser:userId] center];
        label.transform = CGAffineTransformMakeScale(0.3, 0.3);
        label.alpha = 0.3;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (BOOL)isShowNameAnimation
{
    return YES;
}

- (void)hanleItemResponse:(int)itemType
{
    return;
}

@end

