//
//  BBSOptionView.m
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import "BBSOptionView.h"

@interface BBSOptionView()
{
    
}

@end

@implementation BBSOptionView

#define ANIMATION_TIME 0.5

- (void)dealloc
{
    PPRelease(_titles);
    PPRelease(_mask);
    PPRelease(_bgImageView);
    PPRelease(_contentView);
    RELEASE_BLOCK(_callback);
    [super dealloc];
}

- (void)initMaskView
{
    self.mask = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mask.alpha = 0.6;
    [self.mask addTarget:self action:@selector(clickMaskButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mask];
    [self setMaskViewColor:[UIColor lightGrayColor]];
}
- (void)initBGView
{
    self.bgImageView = [[[UIImageView alloc] init] autorelease];
    [self.contentView addSubview:self.bgImageView];
}

- (void)initContentView
{
    self.contentView = [[[UIView alloc] init] autorelease];
    [self addSubview:self.contentView];
}
- (void)baseInit
{
    [self initMaskView];
    [self initContentView];
    [self initBGView];
}

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSOptionViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.titles = titles;
        self.delegate = delegate;
        [self baseInit];
    }
    return self;
}

- (id)initWithTitles:(NSArray *)titles
            callback:(BBSOptionViewCallback)callback
{
    self = [super init];
    if (self) {
        self.titles = titles;
        self.callback = callback;
        [self baseInit];
    }
    return self;
}

- (void)setMaskViewColor:(UIColor *)color
{
    if (color) {
        [self.mask setBackgroundColor:color];
    }
}
- (void)dismiss:(BOOL)animated
{
    if (animated) {
        self.alpha = 1;
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            RELEASE_BLOCK(_callback);
            [self removeFromSuperview];
        }];
    }else{
        RELEASE_BLOCK(_callback);
        [self removeFromSuperview];
    }
}
- (void)show:(BOOL)animated
{
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    [self setFrame:view.bounds];
    [self.mask setFrame:self.bounds];
    [self.bgImageView setFrame:self.contentView.bounds];
    [self show:animated];
}
- (void)clickOptionButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionView:didSelectedButtonIndex:)]) {
        [self.delegate optionView:self didSelectedButtonIndex:button.tag];
    }
    EXECUTE_BLOCK(self.callback, button.tag);
    self.callback = nil;
    [self dismiss:YES];
}

- (void)clickMaskButton:(id)sender
{
    [self dismiss:YES];
}
@end
