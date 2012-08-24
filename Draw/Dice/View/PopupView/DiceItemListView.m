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
#import "FontButton.h"
#import "DiceFontManager.h"
#import "ItemManager.h"

#define TAG_OFFSET_ITEM_BUTTON 20120822

@interface DiceItemListView()
{
    ItemManager *_itemManager;
    BOOL _cutItemEabled;
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
        self.itemList = [NSArray arrayWithObjects:[Item cut], [Item rollAgain], nil];
        _itemManager = [ItemManager defaultManager];
    }

    return self;
}

- (void)disableCutItem
{
    _cutItemEabled = NO;
    
    [[self cutItemButton] setEnabled:NO];
}

- (void)enableCutItem
{
    _cutItemEabled = YES;
    
    [[self cutItemButton] setEnabled:YES];
}

- (UIButton *)cutItemButton
{
    return (UIButton *)[self viewWithTag:TAG_OFFSET_ITEM_BUTTON];
}

- (void)update
{    
    [self clearContent];
    [self showContent];
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
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
                          aboveSubView:view
                              animated:animated];
    
    if (duration != 0) {
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
- (void)clearContent
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showContent
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
                                         title:item.itemName 
                                         count:[NSNumber numberWithInt:[_itemManager amountForItem:item.type]]];        
        [self addSubview:tooButton];
    }
}


#define WIDTH_COUNT_VIEW        (([DeviceDetection isIPAD]) ? 28 : 14 )
#define FONT_SIZE_BUTTON        (([DeviceDetection isIPAD]) ? 36 : 18 )
#define FONT_SIZE_COUNT_LABEL   (([DeviceDetection isIPAD]) ? 20 : 10 )
#define Y_OFFSET_TITLE          (([DeviceDetection isIPAD]) ? -8 : -4 )
- (UIButton *)itemButton:(CGRect)frame 
                     tag:(NSInteger)tag 
                   title:(NSString *)title 
                   count:(NSNumber *)count
{
    FontButton *buttonTemp = [[FontButton alloc] initWithFrame:frame fontName:[[DiceFontManager defaultManager] fontName] pointSize:FONT_SIZE_BUTTON];
    [buttonTemp setBackgroundImage:[[DiceImageManager defaultManager] toolsItemBgImage] forState:UIControlStateNormal];
    buttonTemp.fontLable.text = title;
    buttonTemp.fontLable.frame = CGRectOffset(buttonTemp.fontLable.frame, 0, Y_OFFSET_TITLE);
    [buttonTemp addTarget:self action:@selector(clickToolButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *countImage = nil;
    if ([count intValue] > 0 ) {
        countImage = [[DiceImageManager defaultManager] toolEnableCountBackground];
    } else {
        countImage = [[DiceImageManager defaultManager] toolDisableCountBackground];
    }
    UIImageView *countImageView = [[[UIImageView alloc] initWithImage:countImage] autorelease];
    countImageView.frame = CGRectMake(WIDTH_TOOL_BUTTON - 0.6 * WIDTH_COUNT_VIEW, WIDTH_TOOL_BUTTON - WIDTH_COUNT_VIEW, WIDTH_COUNT_VIEW, WIDTH_COUNT_VIEW);
    UILabel *countLabel = [[[UILabel alloc] initWithFrame:countImageView.frame] autorelease];
    countLabel.text = ([count intValue] >= 100) ? @"N" : [count stringValue];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:FONT_SIZE_COUNT_LABEL];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textAlignment = UITextAlignmentCenter;
    [buttonTemp addSubview:countImageView];
    [buttonTemp addSubview:countLabel];
    
    buttonTemp.tag = tag;
    
    
    if (tag == TAG_OFFSET_ITEM_BUTTON) {
        buttonTemp.enabled = _cutItemEabled;
    }
        
    if ([count intValue] <= 0) {
        buttonTemp.enabled = NO;
    }

    return buttonTemp;
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
