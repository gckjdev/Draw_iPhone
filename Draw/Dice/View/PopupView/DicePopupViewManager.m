//
//  DicePopupViewManager.m
//  Draw
//
//  Created by 小涛 王 on 12-7-30.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DicePopupViewManager.h"
#import "CallDiceView.h"

@interface DicePopupViewManager ()

@property (retain, nonatomic) CallDiceView *callDiceView;
@property (retain, nonatomic) ToolSheetView *toolSheetView;

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
        self.callDiceView = [[[CallDiceView alloc] initWithDice:nil count:0] autorelease];
        self.toolSheetView = [[[ToolSheetView alloc] init] autorelease];
    }
    
    return self;
}


- (void)popupCallDiceViewWithDice:(PBDice *)dice
                            count:(int)count
                           atView:(UIView *)view
                           inView:(UIView *)inView
                         animated:(BOOL)animated
{
    [_callDiceView setDice:dice count:count];
    [_callDiceView popupAtView:view inView:inView animated:animated];
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
