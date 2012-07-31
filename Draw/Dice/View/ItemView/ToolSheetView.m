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

@interface ToolSheetView()
@property (retain, nonatomic) NSArray *buttonImageNameList;
@end



@implementation ToolSheetView
@synthesize buttonImageNameList = _buttonImageNameList;
@synthesize delegate = _delegate;
@synthesize backgroundImageView = _backgroundImageView;


- (void)dealloc
{
    [_buttonImageNameList release];
    [super dealloc];
}


- (id)initWithImageNameList:(NSArray *)imageNameList delegate:(id<ToolSheetViewDelegate>)delegate
{
    self  = [super init];
    if (self) {
        self.buttonImageNameList = imageNameList;
        self.delegate = delegate;
    }
    return self;
}


#define SPACE_BORDE_AND_BUTTON  (([DeviceDetection isIPAD]) ? 20 : 10 )
#define WIDTH_TOOL_BUTTON       (([DeviceDetection isIPAD]) ? 60 : 30 )
#define HEIGHT_SHARP            (([DeviceDetection isIPAD]) ? 20 : 10 )
- (void)showInButton:(UIButton *)button
{
    if (_backgroundImageView == nil) {
        self.backgroundImageView = [[[UIImageView alloc] initWithImage:[[DiceImageManager defaultManager] toolBackground]] autorelease];
        [_backgroundImageView setAlpha:0.5];
    }
    [self addSubview:_backgroundImageView];
    
    int count=0;
    for (NSString *name in _buttonImageNameList) {
        CGFloat yStart = SPACE_BORDE_AND_BUTTON + (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON ) * count;
        UIButton *buttonTemp = [[[UIButton alloc] initWithFrame:CGRectMake(SPACE_BORDE_AND_BUTTON, yStart, WIDTH_TOOL_BUTTON, WIDTH_TOOL_BUTTON)] autorelease];
        [buttonTemp setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        [buttonTemp addTarget:self action:@selector(clickToolButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonTemp.tag = count;
        [self addSubview:buttonTemp];
        count ++;
    }
    
    CGFloat width = 2 * SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON;
    CGFloat height = count * (SPACE_BORDE_AND_BUTTON + WIDTH_TOOL_BUTTON) + SPACE_BORDE_AND_BUTTON + HEIGHT_SHARP;
    CGFloat x = 0.5 * button.frame.size.width - 0.5 * width;
    CGFloat y = - height;
    self.frame = CGRectMake(x, y, width, height);
    
    _backgroundImageView.frame = CGRectMake(0, 0, width, height);
    
    [button addSubview:self];
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
