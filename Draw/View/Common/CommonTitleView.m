//
//  CommonTitleView.m
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import "CommonTitleView.h"
#import "HPThemeManager.h"

#define FRAME (ISIPAD ? CGRectMake(0, 0, 768, 98) : CGRectMake(0, 0, 320, 45))
#define BACK_BUTTON_FRAME (ISIPAD ? CGRectMake(4, 2, 78, 74) : CGRectMake(2, 1, 36, 34))
#define TITLE_FONT (ISIPAD ? [UIFont boldSystemFontOfSize:36] : [UIFont boldSystemFontOfSize:18])

@interface CommonTitleView()
@property (assign, nonatomic) id delegate;
@property (retain, nonatomic) UIButton *backButton;
@property (retain, nonatomic) UIImageView *bgImageView;
@property (retain, nonatomic) UILabel *titleLabel;

@end

@implementation CommonTitleView

- (void)dealloc{
    
    [_backButton release];
    [_bgImageView release];
    [_titleLabel release];
    [super dealloc];
}

+ (CommonTitleView *)createWithTitle:(NSString *)title
                            delegate:(id)delegate{
    
    CommonTitleView *titleView = nil;

    titleView = [[[CommonTitleView alloc] initWithTitle:title
                                               delegate:delegate]       autorelease];

    
    [titleView update];
    
    return titleView;
}

- (void)update{
    
    [_backButton setBackgroundImage:UIThemeImageNamed(@"navigation_back@2x.png") forState:UIControlStateNormal];
    
    _bgImageView.image = UIThemeImageNamed(@"navigation_bg@2x.jpg");
    
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(1, 1);
    _titleLabel.shadowColor = [UIColor blackColor];
}

- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate{
    
    if (self = [super initWithFrame:FRAME]) {
        
        self.delegate = delegate;
        
        self.backButton = [[[UIButton alloc] initWithFrame:BACK_BUTTON_FRAME] autorelease];
//        [self.backButton updateCenterY:self.bounds.size.height/2];
        [_backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.bgImageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        
        CGFloat originX = CGRectGetMaxX(_backButton.frame);
        CGFloat width = self.bounds.size.width - 2 * originX;
        CGRect rect = CGRectMake(originX, 0, width, _backButton.bounds.size.height);
        self.titleLabel = [[[UILabel alloc] initWithFrame:rect] autorelease];
        [_titleLabel updateCenterY:_backButton.center.y];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = TITLE_FONT;
        _titleLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:_bgImageView];
        [self addSubview:_titleLabel];
        [self addSubview:_backButton];
    }
    
    return self;
}

- (void)clickBackButton:(UIButton *)button{
    
    if ([_delegate respondsToSelector:@selector(clickBack:)]) {
        [_delegate clickBack:button];
    }else{
        PPDebug(@"<%s> Click back button but delegate did not response to selector(clickBack:)", __FUNCTION__);
    }
}

@end
