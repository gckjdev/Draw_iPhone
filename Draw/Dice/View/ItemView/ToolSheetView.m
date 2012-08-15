//
//  ToolSheetView.m
//  Draw
//
//  Created by haodong qiu on 12年7月30日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ToolSheetView.h"
#import "DeviceDetection.h"
#import "DiceImageManager.h"
#import "FontButton.h"
#import "DiceFontManager.h"

@interface ToolSheetView()
//@property (retain, nonatomic) NSArray *buttonImageNameList;
@property (retain, nonatomic) NSArray *titleList;
@property (retain, nonatomic) NSArray *countNumberList;
@property (retain, nonatomic) CMPopTipView *popTipView;
@end



@implementation ToolSheetView
@synthesize delegate = _delegate;
@synthesize titleList = _titleList;
@synthesize countNumberList = _countNumberList;
@synthesize popTipView = _popTipView;

- (void)dealloc
{
    [_titleList release];
    [_countNumberList release];
    [_popTipView release];
    [super dealloc];
}


//- (id)initWithTitleList:(NSArray *)titleList 
//        countNumberList:(NSArray *)countNumberList 
//               delegate:(id<ToolSheetViewDelegate>)delegate
//{
//    self  = [super init];
//    if (self) {
//        self.titleList = titleList;
//        self.countNumberList = countNumberList;
//        self.delegate = delegate;
//        [self clearContent];
//        [self showContent];
//    }
//    return self;
//}

- (void)updateWithTitleList:(NSArray *)titleList 
            countNumberList:(NSArray *)countNumberList 
                   delegate:(id<ToolSheetViewDelegate>)delegate
{
    self.titleList = titleList;
    self.countNumberList = countNumberList;
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
    
    //[_popTipView performSelector:@selector(dismissAnimated:) withObject:[NSNumber numberWithBool:YES] afterDelay:3];
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
    for (NSString *title in _titleList) {
        CGFloat yStart = (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON ) * index;
        CGRect toolButtonFrame = CGRectMake(0, yStart, WIDTH_TOOL_BUTTON, WIDTH_TOOL_BUTTON);
        NSInteger toolButtonTag = index;
        
        UIButton *tooButton = [self createToolButton:toolButtonFrame 
                                                 tag:toolButtonTag 
                                               title:title 
                                               count:[_countNumberList objectAtIndex:index]];
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
- (UIButton *)createToolButton:(CGRect)frame 
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
    return buttonTemp;
}


- (void)clickToolButton:(id)sender
{
    UIButton *button = (UIButton*)sender;
    NSInteger selectedIndex = button.tag;
    
    if ([_delegate respondsToSelector:@selector(didSelectTool:)]) {
        [_delegate didSelectTool:selectedIndex];
    }
    
    [self dismissAnimated:YES];
}


#pragma mark - CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByCallingDismissAnimatedMethod:(CMPopTipView *)popTipView;
{
    if ([_delegate respondsToSelector:@selector(didDismissToolSheet)]) {
        [_delegate didDismissToolSheet];
    }
}

@end
