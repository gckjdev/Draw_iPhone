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

#define MESSAGE_BACKGROUND_COLOR [UIColor colorWithRed:177./255. green:218./255. blue:199./255. alpha:0.7]
#define CALL_DICE_VIEW_BACKGROUND_COLOR [UIColor colorWithRed:255./255. green:234./255. blue:80./255. alpha:0.4]

#define SIZE_FONT_OPEN_DICE     ([DeviceDetection isIPAD] ? 36 : 18 )

#define SIZE_FONT_CHAT_MESSAGE  ([DeviceDetection isIPAD] ? 26 : 13 )

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
        self.chatView = [ChatView createChatView];
        [self.chatView loadContent];
        self.diceItemListView = [[[DiceItemListView alloc] init] autorelease];
    }
    
    return self;
}

- (void)popupCallDiceViewWithDice:(int)dice
                            count:(int)count
                           atView:(UIView *)atView
                           inView:(UIView *)inView
                     aboveSubView:(UIView *)siblingSubview
                   pointDirection:(PointDirection)pointDirection
{
    [_callDiceView dismissAnimated:YES];
    
    self.callDiceView = [[[CallDiceView alloc] initWithDice:dice count:count] autorelease];
    
    [_callDiceView popupAtView:atView 
                        inView:inView
                  aboveSubView:siblingSubview
                      animated:YES
                pointDirection:pointDirection];
}

- (void)dismissCallDiceView
{
    [_callDiceView dismissAnimated:YES];
    self.callDiceView = nil;
}

- (void)popupItemListAtView:(UIView *)atView 
               inView:(UIView *)inView
          aboveSubView:(UIView *)siblingSubview
             duration:(int)duration
             delegate:(id<DiceItemListViewDelegate>)delegate 
{
    _diceItemListView.delegate = delegate;
    
    [_diceItemListView update];
    [_diceItemListView popupAtView:atView
                            inView:inView 
                      aboveSubView:siblingSubview
                          duration:duration
                          animated:YES];
}

- (void)enableCutItem
{
    [_diceItemListView enableCutItem];
}

- (void)disableCutItem
{
    [_diceItemListView disableCutItem];
}

- (void)dismissItemListView
{
    [_diceItemListView dismissAnimated:YES];
    self.diceItemListView = nil;
}

- (void)popupMessage:(NSString *)message
              atView:(UIView *)atView
              inView:(UIView *)inView
        aboveSubView:(UIView *)siblingSubview
      pointDirection:(PointDirection)pointDirection
{
    MessageView *messageView = [[[MessageView alloc] initWithFrame:CGRectZero 
                                                           message:message
                                                          fontName:[[DiceFontManager defaultManager] fontName]
                                                         pointSize:SIZE_FONT_CHAT_MESSAGE] autorelease];
    [messageView popupAtView:atView
                      inView:inView
                aboveSubView:siblingSubview
                    duration:3.0
             backgroundColor:MESSAGE_BACKGROUND_COLOR
                    animated:YES
              pointDirection:pointDirection];
}

- (void)popupOpenDiceViewWithOpenType:(int)openType
                               atView:(UIView *)atView
                               inView:(UIView *)inView
                         aboveSubView:siblingSubview
                       pointDirection:(PointDirection)pointDirection
{
    [_openDiceView dismissAnimated:YES];
    
    NSString *message = @"";
    switch (openType) {
        case 0:
            message = NSLS(@"kOpenDiceMessage");
            break;
            
        case 1:
            message = NSLS(@"kScrambleToOpenDiceMessage");
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
                  aboveSubView:siblingSubview
               backgroundColor:CALL_DICE_VIEW_BACKGROUND_COLOR
                      animated:YES
                pointDirection:pointDirection];
}

- (void)dismissOpenDiceView
{
    [_openDiceView dismissAnimated:YES];
    self.openDiceView = nil;
}

- (void)popupChatViewAtView:(UIView *)atView
                     inView:(UIView *)inView 
               aboveSubView:(UIView *)siblingSubview
                  deleagate:(id<ChatViewDelegate>)delegate;
{
    _chatView.delegate = delegate;

    [_chatView popupAtView:atView 
                    inView:inView
              aboveSubView:siblingSubview
                  animated:YES 
            pointDirection:PointDirectionAuto];
}

- (void)dismissChatView
{
    [_chatView dismissAnimated:YES];
    self.chatView = nil;
}

@end
