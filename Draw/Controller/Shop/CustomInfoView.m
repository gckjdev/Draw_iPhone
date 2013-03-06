//
//  CustomInfoView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-5.
//
//

#import "CustomInfoView.h"

@interface CustomInfoView()
@property (retain, nonatomic) UIView *infoView;

@end

@implementation CustomInfoView


- (void)dealloc
{
    [_infoView dealloc];
    [super dealloc];
}

+ (id)createWithTitle:(NSString *)title
                 info:(NSString *)info
{
    return nil;
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
{
    return [self createWithTitle:title infoView:infoView hasCloseButton:YES buttonTitles:nil];
}

+ (id)createWithTitle:(NSString *)title
             infoView:(UIView *)infoView
       hasCloseButton:(BOOL)hasCloseButton
         buttonTitles:(NSString *)firstTitle, ...
{
    UIView *view;
    
    UIButton *button;
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (void) setActionBlock:(ButtonActionBlock)actionBlock {
    if (_actionBlock != actionBlock) {
        Block_release(_actionBlock);
        _actionBlock = Block_copy(actionBlock);
    }
}

- (void)clickButton:(id)sender
{
    _actionBlock(nil, _infoView);
}

@end
