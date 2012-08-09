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
#import "MessageView.h"
#import "LocaleUtils.h"
#import "DiceFontManager.h"

#define MESSAGE_BACKGROUND_COLOR [UIColor yellowColor]
#define CALL_DICE_VIEW_BACKGROUND_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]

@interface DicePopupViewManager ()

@property (retain, nonatomic) CallDiceView *callDiceView;
@property (retain, nonatomic) ToolSheetView *toolSheetView;
@property (retain, nonatomic) MessageView *openDiceView;

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
                           atView:(UIView *)atView
                           inView:(UIView *)inView
                   pointDirection:(PointDirection)pointDirection
{
    [_callDiceView dismissAnimated:YES];
    self.callDiceView = [[[CallDiceView alloc] initWithDice:dice count:count] autorelease];
    [_callDiceView popupAtView:atView inView:inView animated:YES pointDirection:pointDirection];
}

- (void)dismissCallDiceView
{
    [_callDiceView dismissAnimated:YES];
}

- (void)popupToolSheetViewWithImageNameList:(NSArray *)imageNameList 
                            countNumberList:(NSArray *)countNumberList 
                                   delegate:(id<ToolSheetViewDelegate>)delegate 
                                     atView:(UIView *)atView 
                                     inView:(UIView *)inView  
{
    [_toolSheetView updateWithImageNameList:imageNameList 
                            countNumberList:countNumberList
                                   delegate:delegate];
    [_toolSheetView popupAtView:atView inView:inView animated:YES];
}

- (void)dismissToolSheetView
{
    [_toolSheetView dismissAnimated:YES];
}

- (void)popupMessage:(NSString *)message
              atView:(UIView *)atView
              inView:(UIView *)inView
      pointDirection:(PointDirection)pointDirection
{
    MessageView *messageView = [[[MessageView alloc] initWithFrame:CGRectZero 
                                                           message:message
                                                          fontName:[[DiceFontManager defaultManager] fontName]
                                                         pointSize:13] autorelease];
    [messageView popupAtView:atView
                      inView:inView
                    duration:3.0
             backgroundColor:MESSAGE_BACKGROUND_COLOR
                    animated:YES
              pointDirection:pointDirection];
}

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
                             duration:(int)duration
                       pointDirection:(PointDirection)pointDirection
{
    NSString *message = @"";
    switch (openType) {
        case 0:
            message = NSLS(@"kOpenDice");
            break;
            
        case 1:
            message = NSLS(@"kScrambleToOpenDice");
            break;
            
        default:
            message = NSLS(@"kOpenDice");
            break;
    }
    self.openDiceView = [[[MessageView alloc] initWithFrame:CGRectZero 
                                                   message:message
                                                  fontName:[[DiceFontManager defaultManager] fontName]
                                                 pointSize:13] autorelease];
    
    [_openDiceView popupAtView:atView
                        inView:inView
                      duration:duration
               backgroundColor:CALL_DICE_VIEW_BACKGROUND_COLOR
                      animated:YES
                pointDirection:pointDirection];
    
    [_callDiceView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:duration];
}

- (void)dismissOpenDiceView
{
    [_openDiceView dismissAnimated:YES];
}

@end
