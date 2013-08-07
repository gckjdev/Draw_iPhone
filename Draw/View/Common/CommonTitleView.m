//
//  CommonTitleView.m
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import "CommonTitleView.h"
#import "HPThemeManager.h"
#import "UIButton+Extend.h"

#define WIDTH (ISIPAD ? 768 : 320)
#define HEIGH (ISIPAD ? 98 : 45)

#define LEFT_GAP (ISIPAD ? 4 : 2)

#define BACK_BUTTON_WIDTH (ISIPAD ? 78 : 36)
#define BACK_BUTTON_HEIGHT BACK_BUTTON_WIDTH
#define RIGHT_BUTTON_WIDTH (ISIPAD ? 78 : 36)
#define RIGHT_BUTTON_HEIGHT RIGHT_BUTTON_WIDTH

#define TITLE_LABEL_WIDTH (ISIPAD ? 450 : 200)
#define TITLE_LABEL_HEIGHT (ISIPAD ? 78 : 36)

#define TITLE_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:36] : [UIFont boldSystemFontOfSize:18])
#define BUTTON_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:30] : [UIFont boldSystemFontOfSize:15])


@interface CommonTitleView(){
    CGFloat _centerX;
    CGFloat _centerY;
}

@property (assign, nonatomic) SEL backButtonSelctor;

@property (retain, nonatomic) UIImageView *bgImageView;
@property (retain, nonatomic) UIButton *backButton;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIButton *rightButton;


@end

@implementation CommonTitleView

- (void)dealloc{
    
    [_backButton release];
    [_bgImageView release];
    [_titleLabel release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
    
        self.frame = CGRectMake(0, 0, WIDTH, HEIGH);
        _centerX = (self.bounds.size.width/2);
        _centerY = (self.bounds.size.height/2);
        
        self.bgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        _bgImageView.image = UIThemeImageNamed(@"navigation_bg@2x.jpg");
    
        self.backButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        [_backButton updateWidth:BACK_BUTTON_WIDTH];
        [_backButton updateHeight:BACK_BUTTON_HEIGHT];
        [_backButton updateOriginX:LEFT_GAP];
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
        _titleLabel.shadowOffset = CGSizeMake(1, 1);
        _titleLabel.shadowColor = [UIColor blackColor];
        
        [self addSubview:_bgImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_backButton];
        
        
        self.backButtonSelctor = @selector(clickBack:);
    }
    
    return self;
}

- (void)setTitle:(NSString *)title{
    
    _titleLabel.text = title;
}


- (void)setRightButtonAsRefresh{
    
    // Remove the previos one.
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    
    self.rightButton = [self rightButtonWithImage:UIThemeImageNamed(@"navigation_right_button_refresh@2x.png")];
    [self addSubview:_rightButton];
}


- (void)setRightButtonTitle:(NSString *)title{
    
    // Remove the previos one.
    [_rightButton removeFromSuperview];
    _rightButton = nil;
    
    self.rightButton = [self rightButtonWithTitle:title];
    [self addSubview:_rightButton];
}

- (UIButton *)rightButtonWithImage:(UIImage *)image{
    
    CGRect frame = CGRectMake(0, 0, RIGHT_BUTTON_WIDTH, RIGHT_BUTTON_HEIGHT);
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [button setImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    
    int originX = (WIDTH - LEFT_GAP - button.frame.size.width);
    [button updateCenterX:originX];
    [button updateCenterY:_centerY];

    return button;
}

- (UIButton *)rightButtonWithTitle:(NSString *)title{
    
    CGRect frame = CGRectMake(0, 0, RIGHT_BUTTON_WIDTH, RIGHT_BUTTON_HEIGHT);
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = BUTTON_FONT;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [button setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:UIThemeImageNamed(@"") forState:UIControlStateNormal];
    [button wrapTitle];
    
    
    [button addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];

    int originX = (WIDTH - LEFT_GAP - button.frame.size.width);
    [button updateOriginX:originX];
    [button updateCenterY:_centerY];
    
    return button;
}

- (void)clickBackButton:(UIButton *)button{
    
    if ([_target respondsToSelector:_backButtonSelctor]) {
        [_target performSelector:_backButtonSelctor withObject:button];
    }
}

- (void)clickRightButton:(UIButton *)button{
    
    if ([_target respondsToSelector:_rightButtonSelctor] ) {
        [_target performSelector:_rightButtonSelctor withObject:button];
    }
}

@end

