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
#import "OpenDiceView.h"

@interface DicePopupViewManager ()

@property (retain, nonatomic) CallDiceView *callDiceView;
@property (retain, nonatomic) ToolSheetView *toolSheetView;
@property (retain, nonatomic) OpenDiceView *openDiceView;

//- (CMPopTipView *)popTipViewWithCustomView:(UIView *)view
//                          backagroundColor:(UIColor *)color;

@end

static DicePopupViewManager *_instance = nil;

@implementation DicePopupViewManager

@synthesize callDiceView = _callDiceView;
@synthesize toolSheetView = _toolSheetView;
@synthesize openDiceView = _openDiceView;

- (void)dealloc
{
    [_callDiceView release];
    [_toolSheetView release];
    [_openDiceView release];
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

- (void)popupCallDiceViewWithDice:(int)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    [_callDiceView dismissAnimated:animated];
    if (_callDiceView == nil) {
        self.callDiceView = [[CallDiceView alloc] initWithDice:dice count:count];
    }else {
        [_callDiceView setDice:dice count:count];
    }
    
    [_callDiceView popupAtView:view inView:inView animated:animated];
}

- (void)dismissCallDiceViewAnimated:(BOOL)animated
{
    [_callDiceView dismissAnimated:animated];
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

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
                             animated:(BOOL)animated
{
    self.openDiceView = [[[OpenDiceView alloc] initWithOpenType:openType] autorelease];
    [_openDiceView popupAtView:atView inView:inView animated:animated];
}

- (void)dismissOpenDiceViewAnimated:(BOOL)animated
{
    [_openDiceView dismissAnimated:animated];
}

@end
