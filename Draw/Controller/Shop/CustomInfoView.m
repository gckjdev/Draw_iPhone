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
#import "UIImageUtil.h"
#import "CommonDialog.h"

@interface CustomInfoView()
@property (retain, nonatomic) UIActivityIndicatorView *indicator;
@property (assign, nonatomic) CloseHandler closeHandler;

@end


#define TITLE_HEIGHT         ([DeviceDetection isIPAD] ? (68) : (34))
#define SPACE_VERTICAL       ([DeviceDetection isIPAD] ? (30) : (15)) 
#define SPACE_HORIZONTAL     ([DeviceDetection isIPAD] ? (40) : (20))

#define BUTTON_HEIGHT             ([DeviceDetection isIPAD] ? (60) : (30))
#define BUTTON_WIDTH              ([DeviceDetection isIPAD] ? (170) : (85))
#define SPACE_BUTTON_AND_BUTTON   ([DeviceDetection isIPAD] ? (60) : (30))

#define WIDTH_INFO_LABEL          ([DeviceDetection isIPAD] ? (420) : (210))
#define HEIGHT_MIN_INFO_LABEL     ([DeviceDetection isIPAD] ? (200) : (100))
#define HEIGHT_MAX_INFO_LABEL     ([DeviceDetection isIPAD] ? (800) : (400))

#define FONT_SIZE_INFO_LABEL      ([DeviceDetection isIPAD] ? (28) : (14)) 

@implementation CustomInfoView

AUTO_CREATE_VIEW_BY_XIB(CustomInfoView);

- (void)dealloc
{
    [self unregisterAllNotifications];
    PPRelease(_notifications);
    [_indicator release];
    [_infoView release];
    [_mainView release];
    [_titleLabel release];
    [_closeButton release];
    RELEASE_BLOCK(_actionBlock);
    RELEASE_BLOCK(_closeHandler);
    [_mainBgImageView release];
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
         hasEdgeSpace:(BOOL)hasEdgeSpace
{
    return [self createWithTitle:title infoView:infoView hasCloseButton:YES closeHandler:NULL buttonTitles:nil hasEdgeSpace:hasEdgeSpace];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
         closeHandler:(CloseHandler)closeHandler
{
    return [self createWithTitle:title
                        infoView:infoView
                  hasCloseButton:YES
                    closeHandler:closeHandler
                    buttonTitles:nil
                    hasEdgeSpace:YES];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSArray *)buttonTitles
{
    return [self createWithTitle:title
                        infoView:infoView
                  hasCloseButton:hasCloseButton
                    closeHandler:NULL
                    buttonTitles:buttonTitles
                    hasEdgeSpace:YES];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         closeHandler:(CloseHandler)closeHandler
         buttonTitles:(NSArray *)buttonTitles
         hasEdgeSpace:(BOOL)hasEdgeSpace
{
    CustomInfoView *view = [self createView];
    
    view.notifications = [NSMutableDictionary dictionary];
    
    view.infoView = infoView;
    COPY_BLOCK(view.closeHandler, closeHandler);
    
    CGFloat SpaceHorizonal = (hasEdgeSpace ? SPACE_HORIZONTAL : [CommonDialog edgeWidth]);
    CGFloat SpaceVertical = (hasEdgeSpace ? SPACE_VERTICAL : [CommonDialog edgeWidth]);
    // set mainView size
     CGFloat width = SpaceHorizonal*2 + infoView.frame.size.width;
     CGFloat height = TITLE_HEIGHT + SpaceVertical*2 + infoView.frame.size.height;
    
    [view.mainView updateWidth:width];
    [view.mainView updateHeight:height];
    [view.mainBgImageView setImage:[[ShareImageManager defaultManager] customInfoViewMainBgImage]];
    
    // set title
    view.titleLabel.text = title;
    view.titleLabel.textColor = COLOR_WHITE;
    
    // add info view
    [infoView updateOriginX:SpaceHorizonal];
    [infoView updateOriginY:(TITLE_HEIGHT + SpaceVertical)];
    [view.mainView addSubview:infoView];
    
    // set close button
    view.closeButton.hidden = !hasCloseButton;
    
    
    CGFloat originY = TITLE_HEIGHT + SpaceVertical*2 + infoView.frame.size.height;

    if ([buttonTitles count] != 0) {
        [view.mainView updateHeight:(view.mainView.frame.size.height + SpaceVertical + BUTTON_HEIGHT)];
    }
    
    if ([buttonTitles count] == 1) {
        UIButton *button = [self createButtonWithTitle:[buttonTitles objectAtIndex:0]];
        [button updateCenterX:infoView.center.x];
        [button updateOriginY:originY];
        [button addTarget:view action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        
//        [button setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
        
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
        
        
        
//        [button1 setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
//        [button2 setBackgroundImage:[[GameApp getImageManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
        

        [view.mainView addSubview:button1];
        [view.mainView addSubview:button2];
    }
    
    return view;
}

- (void)updateMainViewCenter
{
    self.mainView.center = self.center;
    CGFloat centerY = (self.mainView.center.y - (ISIPAD ? 20 : 10));
    centerY = MIN(centerY, (ISIPAD ? 502 : 230));
    [self.mainView updateCenterY:centerY];
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
#define FONT_SIZE_BUTTON_TITLE ([DeviceDetection isIPAD] ? 30 : 15)
+ (UIButton *)createButtonWithTitle:(NSString *)title{
    UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)] autorelease];
 
    [button setBackgroundColor:COLOR_YELLOW];
    [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    SET_VIEW_ROUND_CORNER(button);
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_BUTTON_TITLE];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    return button;
}

- (void)showInView:(UIView *)view
{
    self.frame = view.bounds;
    [self updateMainViewCenter];
    [view addSubview:self];

    [self.layer addAnimation:[AnimationManager moveVerticalAnimationFrom:(self.superview.frame.size.height*1.5) to:(self.superview.frame.size.height*0.5) duration:0.3] forKey:@""];
}

- (void)dismiss
{
    [self unregisterAllNotifications];    
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
    EXECUTE_BLOCK(_closeHandler);
}

- (void)setTitle:(NSString*)title
{
    [self.titleLabel setText:title];
}

#pragma Notification
#pragma mark -

- (void)registerNotificationWithName:(NSString *)name
                              object:(id)obj
                               queue:(NSOperationQueue *)queue
                          usingBlock:(void (^)(NSNotification *note))block
{
    PPDebug(@"%@ registerNotificationWithName %@", [self description], name);
    NSNotification *notification = [[NSNotificationCenter defaultCenter]
                                    addObserverForName:name
                                    object:obj
                                    queue:queue
                                    usingBlock:block];
    
    [_notifications setObject:notification forKey:name];
}

- (void)registerNotificationWithName:(NSString *)name
                          usingBlock:(void (^)(NSNotification *note))block
{
    if ([_notifications objectForKey:name] != nil) {
        return;
    }
    
    PPDebug(@"%@ registerNotificationWithName %@", [self description], name);
    
    NSNotification *notification = [[NSNotificationCenter defaultCenter]
                                    addObserverForName:name
                                    object:nil
                                    queue:[NSOperationQueue mainQueue]
                                    usingBlock:block];
    
    [_notifications setObject:notification forKey:name];
}


- (void)unregisterNotificationWithName:(NSString *)name
{
    PPDebug(@"%@ unregisterNotificationWithName %@", [self description], name);
    
    NSNotification *notification = [_notifications objectForKey:name];
    [[NSNotificationCenter defaultCenter] removeObserver:notification];
    [_notifications removeObjectForKey:name];
}

- (void)unregisterAllNotifications
{
    [_notifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        //        if ([obj isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)obj;
        [[NSNotificationCenter defaultCenter] removeObserver:notification];
        //        }
        
    }];
    
    [_notifications removeAllObjects];
}

@end
