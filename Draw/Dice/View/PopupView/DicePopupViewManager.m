//
//  DicePopupViewManager.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DicePopupViewManager.h"
#import "CMPopTipView.h"
#import "CallDiceView.h"


@interface DicePopupViewManager ()

@property (retain, nonatomic) CallDiceView *callDiceView;
@property (retain, nonatomic) ToolSheetView *toolSheetView;

//- (CMPopTipView *)popTipViewWithCustomView:(UIView *)view
//                          backagroundColor:(UIColor *)color;

@end

static DicePopupViewManager *_instance = nil;

@implementation DicePopupViewManager

@synthesize callDiceView = _callDiceView;
@synthesize toolSheetView = _toolSheetView;

- (void)dealloc
{
    [_callDiceView release];
    [_toolSheetView release];

    [super dealloc];
}

+ (id)defaultManager
{
    if (_instance == nil) {
        _instance = [[DicePopupViewManager alloc] init];
    }
    
    return _instance;
}

- (id)init
{
    if (self = [super init]) {
        self.toolSheetView = [[[ToolSheetView alloc] init] autorelease];
    }
    
    return self;
}

//- (CMPopTipView *)popTipViewWithCustomView:(UIView *)view
//                          backagroundColor:(UIColor *)color
//{
//    CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithCustomView:view] autorelease];
//    popTipView.backgroundColor = color;
//    return popTipView;
//}


- (void)popupCallDiceViewWithDice:(PBDice *)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    [_callDiceView dismissAnimated:YES];
    if (_callDiceView == nil) {
        self.callDiceView = [[CallDiceView alloc] initWithDice:dice count:count];
    }else {
        [_callDiceView setDice:dice count:count];
    }
    
    [_callDiceView popupAtView:view inView:inView animated:YES];
}

- (void)dismissCallDiceViewAnimated:(BOOL)animated
{
    [_callDiceView dismissAnimated:YES];
}

- (void)popupToolSheetViewWithImageNameList:(NSArray *)imageNameList 
                            countNumberList:(NSArray *)countNumberList 
                                   delegate:(id<ToolSheetViewDelegate>)delegate 
                                     atView:(UIView *)view 
                                     inView:(UIView *)inView  
                                   animated:(BOOL)animated
{
    [_toolSheetView updateWithImageNameList:imageNameList 
                            countNumberList:countNumberList
                                   delegate:delegate];
    [_toolSheetView popupAtView:view inView:inView animated:animated];
}

- (void)dismissToolSheetViewAnimated:(BOOL)animated
{
    [_toolSheetView dismissAnimated:animated];
}

@end
