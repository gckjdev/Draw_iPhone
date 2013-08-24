//
//  CommonTitleView.m
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import "CommonTitleView.h"
#import "HPThemeManager.h"
#import "ShareImageManager.h"
#import "UIImageExt.h"

#define COMMON_TITLE_VIEW_TAG   2013081218

#define LEFT_GAP (ISIPAD ? 4 : 2)

#define BACK_BUTTON_WIDTH (ISIPAD ? 60 : 30)
#define BACK_BUTTON_HEIGHT BACK_BUTTON_WIDTH
#define RIGHT_BUTTON_WIDTH (ISIPAD ? 50 : 25)
#define RIGHT_BUTTON_HEIGHT RIGHT_BUTTON_WIDTH
#define RIGHT_BUTTON_INSET_X (ISIPAD ? -20 : -10)
#define RIGHT_BUTTON_INSET_Y (ISIPAD ? -10 : -5)

#define TITLE_LABEL_WIDTH (ISIPAD ? 450 : 200)
#define TITLE_LABEL_HEIGHT (ISIPAD ? 78 : 36)

#define TITLE_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:40] : [UIFont boldSystemFontOfSize:20])
#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:30] : [UIFont boldSystemFontOfSize:15])


@interface CommonTitleView(){
    CGFloat _centerX;
    CGFloat _centerY;
}

//@property (assign, nonatomic) SEL backButtonSelector;

@property (retain, nonatomic) UIImageView *bgImageView;
@property (retain, nonatomic) UIButton *backButton;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIActivityIndicatorView* loadingActivityView;
@property (retain, nonatomic) NSString* titleText;
@property (assign, nonatomic) BOOL rightButtonBeforeLoadingHiddenState;

@end

@implementation CommonTitleView

- (void)dealloc{
    
    PPRelease(_titleText);
    PPRelease(_loadingActivityView);
    [_backButton release];
    [_bgImageView release];
    [_titleLabel release];
    self.target = nil;
    [super dealloc];
}



+ (CommonTitleView*)createTitleView:(UIView*)superView
{
    CommonTitleView* titleView = [self titleView:superView];
    if (titleView != nil){
        PPDebug(@"<createTitleView> but title view exist, return");
        return titleView;
    }
    
    titleView = [[CommonTitleView alloc] init];
    [superView addSubview:titleView];
    [titleView release];
    return titleView;
}

+ (CommonTitleView*)titleView:(UIView*)superView
{
    UIView* view = [superView viewWithTag:COMMON_TITLE_VIEW_TAG];
    if ([view isKindOfClass:[CommonTitleView class]]){
        return (CommonTitleView*)view;
    }
    else{
        if (view != nil){
            PPDebug(@"<Warning> Title View Not Found or Title View is Not CommonTitleView");
        }
        return nil;
    }
}

- (void)initData
{
    self.frame = CGRectMake(0, 0, COMMON_TITLE_VIEW_WIDTH, COMMON_TITLE_VIEW_HEIGHT);
    _centerX = (self.bounds.size.width/2);
    _centerY = (self.bounds.size.height/2);
    
    self.bgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    _bgImageView.image = UIThemeImageNamed(@"navigation_bg@2x.jpg");
    
    self.backButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
    [_backButton updateWidth:BACK_BUTTON_WIDTH];
    [_backButton updateHeight:BACK_BUTTON_HEIGHT];
    [_backButton updateOriginX:4 * LEFT_GAP];
    [_backButton updateCenterY:_centerY];
    
    [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [_backButton setBackgroundImage:UIThemeImageNamed(@"navigation_back@2x.png") forState:UIControlStateNormal];
    
    self.titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [_titleLabel updateWidth:TITLE_LABEL_WIDTH];
    [_titleLabel updateHeight:TITLE_LABEL_HEIGHT];
    [_titleLabel updateCenterX:_centerX];
    [_titleLabel updateCenterY:_centerY];
    
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = TITLE_FONT;
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(0, 1);
    _titleLabel.shadowColor = COLOR_DARK_BLUE;
    
    [self addSubview:_bgImageView];
    [self addSubview:_titleLabel];
    [self addSubview:_backButton];
    
    self.backButtonSelector = @selector(clickBack:);
    self.tag = COMMON_TITLE_VIEW_TAG;
    
}

- (id)init
{
    self = [super init];
    [self initData];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        [self initData];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title{
    
    self.titleText = title;
    _titleLabel.text = title;
}


- (void)setRightButtonAsRefresh{
    
    // Remove the previos one.
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    
    self.rightButton = [self rightButtonWithImage:UIThemeImageNamed(@"button_refresh@2x.png")];
    [self addSubview:_rightButton];
}


- (void)setRightButtonTitle:(NSString *)title{
    
    // Remove the previos one.
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    
    self.rightButton = [self rightButtonWithTitle:title];
    [self addSubview:_rightButton];
}

- (void)setBgImage:(UIImage *)image
{
    [self.bgImageView setImage:image];
}

- (void)setLeftButtonImage:(UIImage *)image
{
    [_backButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (UIButton *)rightButtonWithImage:(UIImage *)image{
    
    CGRect frame = CGRectMake(0, 0, RIGHT_BUTTON_WIDTH, RIGHT_BUTTON_HEIGHT);
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
//    UIImage* buttonImage = [image imageByScalingAndCroppingForSize:CGSizeMake(RIGHT_BUTTON_IMAGE_WIDTH, RIGHT_BUTTON_IMAGE_WIDTH)];
//    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image forState:UIControlStateNormal];

    
    [button addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    
    int originX = (COMMON_TITLE_VIEW_WIDTH - 3 * LEFT_GAP - button.frame.size.width);
    [button updateOriginX:originX];
    [button updateCenterY:_centerY];

    return button;
}

- (UIButton *)rightButtonWithTitle:(NSString *)title{
    
    CGRect frame = CGRectMake(0, 0, RIGHT_BUTTON_WIDTH, RIGHT_BUTTON_HEIGHT);
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = BUTTON_FONT;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.titleLabel.shadowOffset = CGSizeMake(1, 1);
//    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[[ShareImageManager defaultManager] greenButtonImage:title]
                      forState:UIControlStateNormal];
    
    [button sizeToFit];
    button.frame = CGRectInset(button.frame, RIGHT_BUTTON_INSET_X, RIGHT_BUTTON_INSET_Y);
    
    [button addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];

    int originX = (COMMON_TITLE_VIEW_WIDTH - 3 * LEFT_GAP - button.frame.size.width);
    [button updateOriginX:originX];
    [button updateCenterY:_centerY];
    
    return button;
}

- (void)clickBackButton:(UIButton *)button{
    
    if ([_target respondsToSelector:_backButtonSelector]) {
        [_target performSelector:_backButtonSelector withObject:button];
    }
}

- (void)clickRightButton:(UIButton *)button{
    
    if ([_target respondsToSelector:_rightButtonSelector] ) {
        [_target performSelector:_rightButtonSelector withObject:button];
    }
}

- (void)hideBackButton
{
    [_backButton setHidden:YES];
}

- (void)showBackButton
{
    [_backButton setHidden:NO];
}

- (void)hideRightButton
{
    [_rightButton setHidden:YES];
}

- (void)showRightButton
{
    [_rightButton setHidden:NO];
}

- (CGRect)rightButtonFrame
{
    return [_rightButton frame];
}

- (void)showLoading:(NSString*)loadingText
{
    if (loadingText){
        self.titleLabel.text = loadingText; 
    }
    else{
        self.titleLabel.text = NSLS(@"kLoading");
    }
    
    if (self.loadingActivityView == nil){
        self.loadingActivityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        self.loadingActivityView.frame = self.rightButton.frame;
    }

    [self addSubview:self.loadingActivityView];
    [self.loadingActivityView startAnimating];
    
    // save right button state and then hide it
    self.rightButtonBeforeLoadingHiddenState = self.rightButton.hidden;
    [self hideRightButton];
}

- (void)showLoading
{
    [self showLoading:nil];
}

- (void)hideLoading
{
    // set back title
    [self setTitle:self.titleText];
    
    [self.loadingActivityView stopAnimating];
    [self.loadingActivityView removeFromSuperview];
    
    // restore right button state
    _rightButton.hidden = self.rightButtonBeforeLoadingHiddenState;
}


@end

