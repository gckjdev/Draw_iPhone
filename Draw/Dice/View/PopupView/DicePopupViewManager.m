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

#define SIZE_FONT_OPEN_DICE     ([DeviceDetection isIPAD] ? 36 : 18 )

@interface DicePopupViewManager ()

@property (retain, nonatomic) CallDiceView *callDiceView;
@property (retain, nonatomic) DiceItemListView *diceItemListView;
@property (retain, nonatomic) MessageView *openDiceView;
@property (retain, nonatomic) ChatView *chatView;

@end

static DicePopupViewManager *_instance = nil;

@implementation DicePopupViewManager

@synthesize callDiceView = _callDiceView;
@synthesize diceItemListView = _diceItemListView;
@synthesize openDiceView = _openDiceView;
@synthesize chatView = _chatView;

- (void)dealloc
{
    [_callDiceView release];
    [_diceItemListView release];
    [_openDiceView release];
    [_chatView release];
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
        self.diceItemListView = [[[DiceItemListView alloc] init] autorelease];
        self.chatView = [[[ChatView alloc] init] autorelease];
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

- (void)popupItemListViewAtView:(UIView *)atView 
                         inView:(UIView *)inView 
                       duration:(int)duration
                       delegate:(id<DiceItemListViewDelegate>)delegate 
 
{
    [_diceItemListView updateWithDelegate:delegate];
    [_diceItemListView popupAtView:atView
                            inView:inView 
                          duration:duration
                          animated:YES];
}

- (void)dismissItemListView
{
    [_diceItemListView dismissAnimated:YES];
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
//                             duration:(int)duration
                       pointDirection:(PointDirection)pointDirection
{
    [_openDiceView dismissAnimated:YES];
    
    NSString *message = @"";
    switch (openType) {
        case 0:
            message = NSLS(@"kOpenDice");
            break;
            
        case 1:
            message = NSLS(@"kScrambleToOpenDice");
            break;
            
        case 2:
            message = NSLS(@"kCut");
            break;
            
        default:
            break;
    }
    self.openDiceView = [[[MessageView alloc] initWithFrame:CGRectZero 
                                                   message:message
                                                  fontName:[[DiceFontManager defaultManager] fontName]
                                                 pointSize:SIZE_FONT_OPEN_DICE
                                              textAlignment:UITextAlignmentCenter] autorelease];
    
    [_openDiceView popupAtView:atView
                        inView:inView
//                      duration:duration
               backgroundColor:CALL_DICE_VIEW_BACKGROUND_COLOR
                      animated:YES
                pointDirection:pointDirection];
    
//    [_callDiceView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:duration];
}

- (void)dismissOpenDiceView
{
    [_openDiceView dismissAnimated:YES];
}

- (void)popupChatViewAtView:(UIView *)atView
                     inView:(UIView *)inView   
                  deleagate:(id<ChatViewDelegate>)delegate;


{
    _chatView.delegate = delegate;
    [_chatView popupAtView:atView 
                    inView:inView
                  animated:YES 
            pointDirection:PointDirectionAuto];
}

- (void)dismissChatView
{
    [_chatView dismissAnimated:YES];
}

@end
