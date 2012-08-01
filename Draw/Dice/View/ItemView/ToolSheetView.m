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
#import "CMPopTipView.h"

@interface ToolSheetView()
@property (retain, nonatomic) NSArray *buttonImageNameList;
@property (retain, nonatomic) NSArray *countNumberList;
@end



@implementation ToolSheetView
@synthesize buttonImageNameList = _buttonImageNameList;
@synthesize delegate = _delegate;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize countNumberList = _countNumberList;

- (void)dealloc
{
    [_buttonImageNameList release];
    [_backgroundImageView release];
    [_countNumberList release];
    [super dealloc];
}


- (id)initWithImageNameList:(NSArray *)imageNameList 
            countNumberList:(NSArray *)countNumberList 
                   delegate:(id<ToolSheetViewDelegate>)delegate
{
    self  = [super init];
    if (self) {
        self.buttonImageNameList = imageNameList;
        self.countNumberList = countNumberList;
        self.delegate = delegate;
    }
    return self;
}


#define SPACE_BORDE_AND_BUTTON  (([DeviceDetection isIPAD]) ? 12 : 6 )
#define WIDTH_TOOL_BUTTON       (([DeviceDetection isIPAD]) ? 64 : 32 )
#define HEIGHT_SHARP            (([DeviceDetection isIPAD]) ? 12 : 6 )
#define OFFSET_ANIMATION        (([DeviceDetection isIPAD]) ? 24 : 12 )

- (void)showInView:(UIView *)superView fromFottomPoint:(CGPoint)fromFottomPoint
{
    if (_backgroundImageView == nil) {
        self.backgroundImageView = [[[UIImageView alloc] initWithImage:[[DiceImageManager defaultManager] toolBackground]] autorelease];
        [_backgroundImageView setAlpha:1];
    }
    [self addSubview:_backgroundImageView];
    
    int index = 0;
    for (NSString *name in _buttonImageNameList) {
        CGFloat yStart = SPACE_BORDE_AND_BUTTON + (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON ) * index;
        CGRect toolButtonFrame = CGRectMake(SPACE_BORDE_AND_BUTTON, yStart, WIDTH_TOOL_BUTTON, WIDTH_TOOL_BUTTON);
        NSInteger toolButtonTag = index;
        
        UIButton *tooButton = [self createToolButton:toolButtonFrame 
                                                 tag:toolButtonTag 
                                           imageName:name 
                                               count:[_countNumberList objectAtIndex:index]];
        [self addSubview:tooButton];
        index ++;
    }
    
    CGFloat width = 2 * SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON;
    CGFloat height = index * (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON) + SPACE_BORDE_AND_BUTTON + HEIGHT_SHARP;
    CGFloat x = fromFottomPoint.x - 0.5 * width;
    CGFloat y = fromFottomPoint.y- height;
    
    self.frame = CGRectMake(x, y + OFFSET_ANIMATION , width, height);
    _backgroundImageView.frame = CGRectMake(0, 0, width, height);
    [superView addSubview:self];
    
    self.alpha = 0.5;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    self.frame = CGRectMake(x, y, width, height);
    self.alpha = 1.0;
    [UIImageView commitAnimations];
}

#define WIDTH_COUNT_VIEW    (([DeviceDetection isIPAD]) ? 28 : 14 )
#define FONT_COUNT_LABEL    (([DeviceDetection isIPAD]) ? 20 : 10 )
- (UIButton *)createToolButton:(CGRect)frame 
                           tag:(NSInteger)tag 
                     imageName:(NSString *)imageName 
                         count:(NSNumber *)count
{
    UIButton *buttonTemp = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
    [buttonTemp setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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
    countLabel.font = [UIFont systemFontOfSize:FONT_COUNT_LABEL];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textAlignment = UITextAlignmentCenter;
    [buttonTemp addSubview:countImageView];
    [buttonTemp addSubview:countLabel];
    
    buttonTemp.tag = tag;
    return buttonTemp;
}


- (void)clickToolButton:(id)sender
{
    [self removeFromSuperview];
    
    UIButton *button = (UIButton*)sender;
    NSInteger selectedIndex = button.tag;
    
    if ([_delegate respondsToSelector:@selector(didSelectTool:)]) {
        [_delegate didSelectTool:selectedIndex];
    }
}


@end
