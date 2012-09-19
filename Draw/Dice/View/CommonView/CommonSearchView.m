//
//  CommonSearchView.m
//  Draw
//
//  Created by Orange on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonSearchView.h"
#import "DiceImageManager.h"

@implementation CommonSearchView
@synthesize contentBackground;
@synthesize keywordInputField;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    [self.contentBackground setImage:[DiceImageManager defaultManager].inputBackgroundImage];
}

+ (CommonSearchView*)showInView:(UIView*)view 
           byTheme:(CommonSearchViewTheme)theme 
           atPoint:(CGPoint)point 
          delegate:(id<CommonSearchViewDelegate, CommonInfoViewDelegate>)delegate
{
    CommonSearchView* searchView;
    switch (theme) {
        case CommonSearchViewThemeDice:
        default:
            searchView = (CommonSearchView*)[self createInfoViewByXibName:@"CommonSearchView"];
            break;
    }
    [searchView initView];
    [searchView showInView:view atPoint:point];
    searchView.delegate = delegate;
    searchView.disappearDelegate = delegate;
    [searchView.keywordInputField becomeFirstResponder];
    return searchView;
}

- (void)showInView:(UIView *)view atPoint:(CGPoint)point
{
    [view addSubview:self];
    [self setCenter:point];
    [self appear];
}

- (void)disappear
{
    [super disappear];
    [self.keywordInputField resignFirstResponder];
}


- (IBAction)clickClose:(id)sender
{
    [self disappear];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_delegate && [_delegate respondsToSelector:@selector(willSearch:byView:)]) {
        [_delegate willSearch:self.keywordInputField.text byView:self];
        [self.keywordInputField resignFirstResponder];
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [contentBackground release];
    [keywordInputField release];
    [super dealloc];
}
@end
