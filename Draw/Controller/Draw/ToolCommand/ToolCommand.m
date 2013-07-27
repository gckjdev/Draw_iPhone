//
//  ToolCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "ToolCommand.h"
#import "UserGameItemManager.h"
#import "BuyItemView.h"
#import "DrawSlider.h"
#import "EditDescCommand.h"
#import "UserService.h"

@implementation ToolCommand

- (void)dealloc
{
    PPRelease(_popTipView);
    [super dealloc];
}

- (BOOL)hasItem:(ItemType)type
{
    return [[UserGameItemManager defaultManager] hasItem:type];
}

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super init];
    if (self) {
        self.control = control;
        self.itemType = itemType;
        if (![self hasItem:itemType]) {
            self.control.selected = YES;
        }
        
    }
    return self;
}


- (BOOL)canUseItem:(ItemType)type
{
    if ([[UserService defaultService] checkAndAskLogin:[self.control theTopView]] == YES){
        return NO;
    }    
    
    if ([self hasItem:type]) {
        return YES;
    }
    
    __block typeof(self) cp = self;
    
    [BuyItemView showOnlyBuyItemView:type inView:[self.control theTopView]
                       resultHandler:^(int resultCode, int itemId, int count, NSString *toUserId) {
        if (resultCode == ERROR_SUCCESS) {
            [cp buyItemSuccessfully:type];
        }
    }];
    
    NSLog(@"You CAN'T use item = %d", type);
    
    return NO;
}

- (BOOL)execute
{
    if (_showing) {
        [self hidePopTipView];
        return NO;
    }
    if ([self canUseItem:self.itemType]) {
        [self sendAnalyticsReport];
        return YES;
    }
    return NO;
}


#define VALUE(X) (ISIPAD ? 2*X : X)
#define POP_POINTER_SIZE VALUE(8.0)


- (void)updatePopTipView:(CMPopTipView *)popTipView
{
    [popTipView setBackgroundColor:[UIColor colorWithRed:255./255. green:255./255. blue:255./255. alpha:0.95]];
    [popTipView setPointerSize:POP_POINTER_SIZE];
    [popTipView setDelegate:self];
}


- (void)showPopTipView
{

    UIView *contentView = [self contentView];
    if (contentView) {
        _showing = YES;
        self.popTipView = [[[CMPopTipView alloc] initWithCustomView:contentView] autorelease];
        self.popTipView.delegate = self;
        [self.popTipView presentPointingAtView:self.control inView:[self.control theTopView] animated:YES];
        [self updatePopTipView:self.popTipView];
    }
}
- (void)hidePopTipView
{
    _showing = NO;
    [self.popTipView dismissAnimated:YES];
    self.popTipView = nil;
}

//need to be override by the sub classes
- (UIView *)contentView
{
    return nil;
}

- (void)buyItemSuccessfully:(ItemType)type
{
    self.control.selected = NO;
}


- (void)sendAnalyticsReport
{
    
}

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    self.popTipView = nil;
    _showing = NO;
}

- (void)updateToolPanel
{
    [self.toolPanel updateWithDrawInfo:self.drawInfo];
}

@end



@interface ToolCommandManager()
{
    NSMutableArray *commandList;
}
@end




ToolCommandManager *_staticToolCommandManager = nil;

NSUInteger _ManagerVersion = 1;

@implementation ToolCommandManager

- (NSUInteger)createVersion
{
    return ++_ManagerVersion;
}

- (void)dealloc
{
    [commandList removeAllObjects];
    PPRelease(commandList);
    [super dealloc];
}

+ (id)defaultManager
{
    if (_staticToolCommandManager == nil) {
        _staticToolCommandManager = [[ToolCommandManager alloc] init];
    }
    return _staticToolCommandManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        commandList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerCommand:(ToolCommand *)command
{
    [commandList addObject:command];
}
- (void)unregisterCommand:(ToolCommand *)command
{
    [commandList removeObject:command];
}
- (ToolCommand *)commandForControl:(UIControl *)control
{
    for (ToolCommand *command in commandList) {
        if (command.control == control) {
            return command;
        }
    }
    return nil;
}
- (void)removeAllCommand:(NSUInteger)version
{
    if (self.version == version) {
        [commandList removeAllObjects];        
    }
}

- (void)hideAllPopTipViews
{
    for (ToolCommand *command in commandList) {
        if (command.isShowing) {
            [command hidePopTipView];
        }

    }
}

- (void)hideAllPopTipViewsExcept:(ToolCommand *)command
{
    for (ToolCommand *command1 in commandList) {
        if (command != command1 && command1.isShowing) {
            [command1 hidePopTipView];
        }
    }
}

- (void)makeCommanActive:(ToolCommand *)command
{
    for (ToolCommand *command1 in commandList) {
        if (command != command1) {
            [command1 hidePopTipView];
        }
    }
}

- (void)updatePanel:(DrawToolPanel *)panel
{
    for (ToolCommand *command in commandList) {
        [command setToolPanel:panel];
    }
}

- (BOOL)isPaletteShowing
{
    for (ToolCommand *command in commandList) {
        if (command.itemType == PaletteItem) {
            return command.isShowing;
        }
    }
    return NO;
}

- (void)resetAlpha
{
    for (ToolCommand *command in commandList) {
        if (command.itemType == ColorAlphaItem) {
            DrawSlider* slider =(DrawSlider *)command.control;
            [slider setValue:1];
            return;
        }
    }
}

- (InputAlertView *)inputAlertView
{
    for (ToolCommand *command in commandList) {
        if ([command isKindOfClass:[EditDescCommand class]]) {
            return [(EditDescCommand *)command inputAlertView];
        }
    }
    
    return nil;
}
@end