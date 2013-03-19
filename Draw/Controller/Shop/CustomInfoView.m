//
//  CustomInfoView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-5.
//
//

#import "CustomInfoView.h"
#import "AutoCreateViewByXib.h"
#import "ShareImageManager.h"
#import "UIViewUtils.h"
#import "AnimationManager.h"
#import "BlockUtils.h"

@interface CustomInfoView()
@property (retain, nonatomic) UIView *infoView;
@property (retain, nonatomic) UIActivityIndicatorView *indicator;
@end


#define TITLE_HEIGHT         ([DeviceDetection isIPAD] ? (60) : (30))
#define SPACE_VERTICAL       ([DeviceDetection isIPAD] ? (20) : (10)) 
#define SPACE_HORIZONTAL     ([DeviceDetection isIPAD] ? (40) : (20))

#define BUTTON_HEIGHT             ([DeviceDetection isIPAD] ? (60) : (30))
#define BUTTON_WIDTH              ([DeviceDetection isIPAD] ? (200) : (100))
#define SPACE_BUTTON_AND_BUTTON   ([DeviceDetection isIPAD] ? (40) : (20))

#define WIDTH_INFO_LABEL          ([DeviceDetection isIPAD] ? (420) : (210))
#define HEIGHT_MIN_INFO_LABEL     ([DeviceDetection isIPAD] ? (200) : (100))
#define HEIGHT_MAX_INFO_LABEL     ([DeviceDetection isIPAD] ? (800) : (400))

#define FONT_SIZE_INFO_LABEL      ([DeviceDetection isIPAD] ? (28) : (14)) 

@implementation CustomInfoView

AUTO_CREATE_VIEW_BY_XIB(CustomInfoView);

- (void)dealloc
{
    [_indicator release];
    [_infoView release];
    [_mainView release];
    [_titleLabel release];
    [_closeButton release];
    RELEASE_BLOCK(_actionBlock);
    [super dealloc];
}

+ (id)createWithTitle:(NSString *)title
                 info:(NSString *)info
{
    UILabel *infoLabel = [self createInfoLabel:info];
    return [self createWithTitle:title infoView:infoLabel];
}

+ (id)createWithTitle:(NSString *)title
                 info:(NSString *)info
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSArray *)buttonTitles
{
    UILabel *infoLabel = [self createInfoLabel:info];
    return [self createWithTitle:title infoView:infoLabel hasCloseButton:hasCloseButton buttonTitles:buttonTitles];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
{
    return [self createWithTitle:title infoView:infoView hasCloseButton:YES buttonTitles:nil];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSArray *)buttonTitles
{
    CustomInfoView *view = [self createView];
        
    view.infoView = infoView;
    
    // set mainView size
    CGFloat width = SPACE_HORIZONTAL + infoView.frame.size.width + SPACE_HORIZONTAL;
    CGFloat height = TITLE_HEIGHT + SPACE_VERTICAL + infoView.frame.size.height + SPACE_VERTICAL;
    [view.mainView updateWidth:width];
    [view.mainView updateHeight:height];
    
    // set title
    view.titleLabel.text = title;
    
    // add info view
    [infoView updateOriginX:SPACE_HORIZONTAL];
    [infoView updateOriginY:(TITLE_HEIGHT + SPACE_VERTICAL)];
    [view.mainView addSubview:infoView];
    
    // set close button
    view.closeButton.hidden = !hasCloseButton;
    
    
    CGFloat originY = TITLE_HEIGHT + SPACE_VERTICAL + infoView.frame.size.height + SPACE_VERTICAL;

    if ([buttonTitles count] != 0) {
        [view.mainView updateHeight:(view.mainView.frame.size.height + SPACE_VERTICAL + BUTTON_HEIGHT)];
    }
    
    if ([buttonTitles count] == 1) {
        UIButton *button = [self createButtonWithTitle:[buttonTitles objectAtIndex:0]];
        [button updateCenterX:infoView.center.x];
        [button updateOriginY:originY];
        [button addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        
        [view.mainView addSubview:button];
    }
    
    if ([buttonTitles count] >= 2) {
        UIButton *button1 = [self createButtonWithTitle:[buttonTitles objectAtIndex:0]];
        UIButton *button2 = [self createButtonWithTitle:[buttonTitles objectAtIndex:1]];
        [button1 updateOriginX:infoView.frame.origin.x];
        [button1 updateOriginY:originY];
        [button1 addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button1.tag = 0;

        [button2 updateOriginX:(infoView.frame.origin.x + infoView.frame.size.width - button2.frame.size.width)];
        [button2 updateOriginY:originY];
        [button2 addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button2.tag = 1;

        [view.mainView addSubview:button1];
        [view.mainView addSubview:button2];
    }
    
    [view.mainView updateCenterY:(view.center.y - 10)];
    
    return view;
}

- (void)enableButtons:(BOOL)enabled
{
    for (UIView *view in [self.mainView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).enabled = enabled;
        }
    }
}

- (void) setActionBlock:(ButtonActionBlock)actionBlock {
    if (_actionBlock != actionBlock) {
        RELEASE_BLOCK(_actionBlock);
        COPY_BLOCK(_actionBlock, actionBlock);
    }
}


+ (UILabel *)createInfoLabel:(NSString *)text
{
    UILabel *infoLabel = [[[UILabel alloc] init] autorelease];
    infoLabel.font = [UIFont systemFontOfSize:FONT_SIZE_INFO_LABEL];
    infoLabel.textColor = [UIColor colorWithRed:108.0/255.0 green:70.0/255.0 blue:33.0/255.0 alpha:1];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setNumberOfLines:0];
    infoLabel.text = text;
    
    // set info label height
    CGSize maxSize = CGSizeMake(WIDTH_INFO_LABEL, HEIGHT_MAX_INFO_LABEL);
    CGSize size = [infoLabel.text sizeWithFont:infoLabel.font constrainedToSize:maxSize];
    if (size.height < HEIGHT_MIN_INFO_LABEL) {
        size = CGSizeMake(size.width, HEIGHT_MIN_INFO_LABEL);
    }
    infoLabel.frame = CGRectMake(0, 0, WIDTH_INFO_LABEL, size.height);
    
    return infoLabel;
}

#define COLOR_BUTTON_TITLE  [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:16.0/255.0 alpha:1]
#define FONT_SIZE_BUTTON_TITLE ([DeviceDetection isIPAD] ? 32 : 16)
+ (UIButton *)createButtonWithTitle:(NSString *)title{
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
    [button setBackgroundImage:[[ShareImageManager defaultManager] dialogButtonBackgroundImage] forState:UIControlStateNormal];
    [button setTitleColor:COLOR_BUTTON_TITLE forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_BUTTON_TITLE];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    return button;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self.layer addAnimation:[AnimationManager moveVerticalAnimationFrom:(self.superview.frame.size.height*1.5) to:(self.superview.frame.size.height*0.5) duration:0.3] forKey:@""];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)showActivity
{
    if (self.indicator == nil) {
        self.indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        [self.indicator updateCenterX:(self.mainView.frame.size.width/2)];
        [self.indicator updateCenterY:(self.mainView.frame.size.height/2)];
        [self.mainView addSubview:self.indicator];
    }
    
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    self.mainView.userInteractionEnabled = NO;
    [self enableButtons:NO];
}

- (void)hideActivity
{
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
    self.mainView.userInteractionEnabled = YES;
    [self enableButtons:YES];
}

- (void)clickButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (_actionBlock) {
        _actionBlock(button, _infoView);
    }
}

- (IBAction)clickCloseButton:(id)sender {
    [self dismiss];
}

@end
