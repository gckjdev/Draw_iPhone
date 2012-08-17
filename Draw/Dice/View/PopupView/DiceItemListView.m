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

@interface DiceItemListView()
{
    ItemManager *_itemManager;
}
@property (retain, nonatomic) NSArray *itemList;
@property (retain, nonatomic) CMPopTipView *popTipView;
@end



@implementation DiceItemListView
@synthesize itemList = _itemList;
@synthesize delegate = _delegate;

@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_popTipView release];
    [super dealloc];
}


- (id)init
{
    if (self = [super init]) {
        self.itemList = [NSArray arrayWithObjects:[Item rollAgain], [Item cut], nil];
        _itemManager = [ItemManager defaultManager];
    }

    return self;
}

- (void)updateWithDelegate:(id<DiceItemListViewDelegate>)delegate
{
    self.delegate = delegate;
    [self clearContent];
    [self showContent];
}

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           animated:(BOOL)animated
{
    [self.popTipView dismissAnimated:YES];
    self.popTipView = [[[CMPopTipView alloc] initWithCustomView:self needBubblePath:NO] autorelease];
    self.popTipView.delegate = self;
    self.popTipView.disableTapToDismiss = YES;
    _popTipView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:213.0/255.0 blue:78.0/255.0 alpha:0.9];
    [_popTipView presentPointingAtView:view inView:inView animated:animated];
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
    int index = 0;
    for (Item *item in _itemList) {
        CGFloat yStart = (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON ) * index;
        CGRect toolButtonFrame = CGRectMake(0, yStart, WIDTH_TOOL_BUTTON, WIDTH_TOOL_BUTTON);
        NSInteger toolButtonTag = index;
        
        UIButton *tooButton = [self itemButton:toolButtonFrame 
                                           tag:toolButtonTag 
                                         title:item.itemName 
                                         count:[NSNumber numberWithInt:[_itemManager amountForItem:item.type]]];
        [self addSubview:tooButton];
        index ++;
    }
    
    CGFloat width = WIDTH_TOOL_BUTTON;
    CGFloat height = index * (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON) - SPACE_BORDE_AND_BUTTON;
    
    self.frame = CGRectMake(0, 0 , width, height);
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
    countLabel.text = [count stringValue];
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:FONT_SIZE_COUNT_LABEL];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textAlignment = UITextAlignmentCenter;
    [buttonTemp addSubview:countImageView];
    [buttonTemp addSubview:countLabel];
    
    buttonTemp.tag = tag;
    
    if (count <= 0) {
        buttonTemp.userInteractionEnabled = NO;
    }
    
    return buttonTemp;
}


- (void)clickToolButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger selectedIndex = button.tag;
    
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
