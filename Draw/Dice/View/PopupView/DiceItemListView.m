//
//  DiceItemListView.m
//  Draw
//
//  Created by haodong qiu on 12年7月30日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "DiceItemListView.h"
#import "DeviceDetection.h"
#import "DiceImageManager.h"
#import "DiceFontManager.h"
#import "ItemManager.h"
#import "UIViewUtils.h"
#import "DiceGameService.h"
#import "UserManager.h"
#import "CommonDiceItemAction.h"

#define TAG_OFFSET_ITEM_BUTTON 201208
#define TAG_ITEM_COUNT_LABEL 158
#define TAG_ITEM_COUNT_IMAGE 159

#define COUNT_IMAGE_VIEW_FRAME CGRectMake(WIDTH_TOOL_BUTTON - 0.6 * WIDTH_COUNT_VIEW, WIDTH_TOOL_BUTTON - WIDTH_COUNT_VIEW, WIDTH_COUNT_VIEW, WIDTH_COUNT_VIEW)

@interface DiceItemListView()
{
    ItemManager *_itemManager;
    DiceGameService *_diceGameService;
    UserManager *_userManager;
}
@property (retain, nonatomic) NSArray *itemList;
@property (retain, nonatomic) CMPopTipView *popTipView;

@end

@implementation DiceItemListView

@synthesize delegate = _delegate;
@synthesize itemList = _itemList;
@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_itemList release];
    [_popTipView release];
    [super dealloc];
}


- (id)init
{
    if (self = [super init]) {
        self.itemList = [NSArray arrayWithObjects:[Item cut], [Item rollAgain], [Item peek], [Item postpone], [Item urge], [Item turtle], [Item diceRobot], [Item reverse], nil];
        _itemManager = [ItemManager defaultManager];
        _diceGameService = [DiceGameService defaultService];
        _userManager = [UserManager defaultManager];
        [self initView];
    }

    return self;
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
       aboveSubView:(UIView *)siblingSubview
           duration:(int)duration
           animated:(BOOL)animated
{
    [self.popTipView dismissAnimated:YES];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self needBubblePath:NO] autorelease];
    self.popTipView.delegate = self;
    self.popTipView.disableTapToDismiss = YES;
    _popTipView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:213.0/255.0 blue:78.0/255.0 alpha:0.9];
    
    [_popTipView presentPointingAtView:view
                                inView:inView 
                             aboveView:siblingSubview
                              animated:animated];
    
    if (duration != 0 ) {
        [self performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:animated] afterDelay:duration];
    }
}

- (void)dismissAnimated:(BOOL)animated 
{
    [_popTipView dismissAnimated:YES];
    self.popTipView = nil;
}


#define SPACE_BORDE_AND_BUTTON  (([DeviceDetection isIPAD]) ? 12 : 6 )
#define WIDTH_TOOL_BUTTON       (([DeviceDetection isIPAD]) ? 64 : 32 )
#define HEIGHT_SHARP            (([DeviceDetection isIPAD]) ? 12 : 6 )
#define OFFSET_ANIMATION        (([DeviceDetection isIPAD]) ? 24 : 12 )

- (void)initView
{
    CGFloat width = WIDTH_TOOL_BUTTON;
    CGFloat height = [_itemList count] * (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON) - SPACE_BORDE_AND_BUTTON;
    
    self.frame = CGRectMake(0, 0 , width, height);
    
    for (int index = 0; index < [_itemList count]; index ++) {
        Item *item = [_itemList objectAtIndex:index];
        
        CGFloat yStart = height - (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON ) * (index + 1) + SPACE_BORDE_AND_BUTTON;
        
        CGRect toolButtonFrame = CGRectMake(0, yStart, WIDTH_TOOL_BUTTON, WIDTH_TOOL_BUTTON);
        NSInteger toolButtonTag = index + TAG_OFFSET_ITEM_BUTTON;
        
        UIButton *tooButton = [self itemButton:toolButtonFrame 
                                           tag:toolButtonTag
                                          item:item];        
        [self addSubview:tooButton];
    }
}


#define WIDTH_COUNT_VIEW        (([DeviceDetection isIPAD]) ? 28 : 14 )
#define FONT_SIZE_BUTTON        (([DeviceDetection isIPAD]) ? 34 : 17 )
#define FONT_SIZE_COUNT_LABEL   (([DeviceDetection isIPAD]) ? 20 : 10 )
#define Y_OFFSET_TITLE          (([DeviceDetection isIPAD]) ? -8 : -4 )
- (UIButton *)itemButton:(CGRect)frame 
                     tag:(NSInteger)tag 
                    item:(Item*)item
{
    
    //NSString *title = item.shortName;
    
    UIButton *buttonTemp = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [buttonTemp.titleLabel setFont:[UIFont systemFontOfSize:FONT_SIZE_BUTTON]];
    [buttonTemp setBackgroundImage:item.itemImage forState:UIControlStateNormal];
    //buttonTemp.fontLable.text = title;
    buttonTemp.titleLabel.frame = CGRectOffset(buttonTemp.titleLabel.frame, 0, Y_OFFSET_TITLE);
    [buttonTemp addTarget:self action:@selector(clickToolButton:) forControlEvents:UIControlEventTouchUpInside];
    buttonTemp.tag = tag;

    UIImageView *countImageView = [[[UIImageView alloc] initWithFrame:COUNT_IMAGE_VIEW_FRAME] autorelease];
    countImageView.tag = TAG_ITEM_COUNT_IMAGE;
    [buttonTemp addSubview:countImageView];
    
    UILabel *countLabel = [[[UILabel alloc] initWithFrame:COUNT_IMAGE_VIEW_FRAME] autorelease];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:FONT_SIZE_COUNT_LABEL];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.tag = TAG_ITEM_COUNT_LABEL;
    [buttonTemp addSubview:countLabel];

    return buttonTemp;
}

- (BOOL)isPopup
{
    return _popTipView.isPopup;
}

- (void)updateView
{
    for (int index = 0; index < [_itemList count]; index ++) {
        Item *item = [_itemList objectAtIndex:index];
        NSInteger itemButtonTag = index + TAG_OFFSET_ITEM_BUTTON;

        UIButton *itemButton = (UIButton *)[self viewWithTag:itemButtonTag];
        UIImageView *countImageView = (UIImageView*)[itemButton viewWithTag:TAG_ITEM_COUNT_IMAGE];
        UILabel *countLabel = (UILabel*)[itemButton viewWithTag:TAG_ITEM_COUNT_LABEL];

        NSNumber *count = [NSNumber numberWithInt:[_itemManager amountForItem:item.type]];
        UIImage *countImage = nil;
        if ([count intValue] > 0 ) {
            countImage = [[DiceImageManager defaultManager] toolEnableCountBackground];
        } else {
            countImage = [[DiceImageManager defaultManager] toolDisableCountBackground];
        }
        countImageView.image = countImage;
        
        countLabel.text = ([count intValue] >= 100) ? @"N" : [count stringValue];
        
        itemButton.enabled = [self canEableItemButton:item.type];
    }
}

- (BOOL)canEableItemButton:(ItemType)itemType 
{
    return [CommonDiceItemAction meetUseScene:itemType];
//    NSNumber *count = [NSNumber numberWithInt:[_itemManager amountForItem:itemType]];
//    if ([count intValue] <= 0 || _diceGameService.diceSession.isMeAByStander) {
//        return NO;
//    }
//    
//    BOOL enabled;
//
//    NSString *currentPlayUserId = _diceGameService.session.currentPlayUserId;
//    BOOL isMyTurn = [_userManager isMe:currentPlayUserId];
//    
//    switch (itemType) {
//        case ItemTypeCut:
//        case ItemTypeDoubleKill:
//            if (_diceGameService.lastCallUserId != nil 
//                && ![_userManager isMe:_diceGameService.lastCallUserId])
//            {
//                enabled = YES;  
//            }else {
//                enabled = NO;
//            }
//            
//            break;
//            
//        case ItemTypeIncTime:
//        case ItemTypeDecTime:
//        case ItemTypeReverse:
//        case ItemTypeDiceRobot:
//        case ItemTypeSkip:
//            if (isMyTurn) {
//                enabled = YES;
//            }else {
//                enabled = NO;
//            }
//
//            break;
//            
//        default:
//            enabled = YES;
//            break;
//    }
//
//    return enabled;
}

- (void)clickToolButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger selectedIndex = button.tag - TAG_OFFSET_ITEM_BUTTON;
    
    Item *item = [_itemList objectAtIndex:selectedIndex];
    
    if ([_delegate respondsToSelector:@selector(didSelectItem:)]) {
        [_delegate didSelectItem:item];
    }
    
    [self dismissAnimated:YES];
}


#pragma mark - CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView;
{
    if ([_delegate respondsToSelector:@selector(didDismissItemListView)]) {
        [_delegate didDismissItemListView];
    }
}

@end
