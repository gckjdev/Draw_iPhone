//
//  BBSPopupSelectionView.m
//  Draw
//
//  Created by gamy on 12-11-30.
//
//

#import "BBSPopupSelectionView.h"
#import "BBSViewManager.h"

//#define ISIPAD [DeviceDetection isIPAD]

#define SPACE_TOP_BUTTON (ISIPAD ? 7*2 : 7)
#define SPACE_BOTTOM_BUTTON (ISIPAD ? 15*2 : 15)
#define SPACE_LEFTRIGHT_BUTTON (ISIPAD ? 8*2 : 8)
#define SPACE_BUTTON_BUTTON (ISIPAD ? 7*2 : 7)

#define SPACE_LEFTRIGHT_TIP (ISIPAD ? 30*2 : 30)

#define BUTTON_SIZE (ISIPAD ? CGSizeMake(100,46) : CGSizeMake(47,22))

@implementation BBSPopupSelectionView

- (void)dealloc
{
    [super dealloc];
}


- (void)updateFrameWithSuperView:(UIView *)view showAbovePoint:(CGPoint )point
{
    NSInteger count = [self.titles count];
    CGFloat width = count * BUTTON_SIZE.width + (count - 1) *SPACE_BUTTON_BUTTON;
    width += (SPACE_LEFTRIGHT_BUTTON * 2);
    CGFloat height = BUTTON_SIZE.height + SPACE_TOP_BUTTON + SPACE_BOTTOM_BUTTON;
    CGFloat y = -height + point.y;
    CGFloat x = 0;
    //if tip at left
    if (point.x < view.center.x) {
        x = point.x - SPACE_LEFTRIGHT_TIP;
        
    }else{
        x = point.x + SPACE_LEFTRIGHT_TIP - width;
    }
    self.contentView.frame = CGRectMake(x, y, width, height);
}
- (void)updateButtons
{
    NSInteger i = 0;
    for(NSString *title in self.titles){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat y = SPACE_TOP_BUTTON;
        CGFloat x = SPACE_LEFTRIGHT_BUTTON + i *(SPACE_BUTTON_BUTTON + BUTTON_SIZE.width);
        button.frame = CGRectMake(x, y, BUTTON_SIZE.width, BUTTON_SIZE.height);
        button.tag = i;
        [button addTarget:self
                   action:@selector(clickOptionButton:)
         forControlEvents:UIControlEventTouchUpInside];
        
        ++i;
        [self.contentView addSubview:button];
        
        
        BBSImageManager *imageManager = [BBSImageManager defaultManager];
        BBSFontManager *fontManager = [BBSFontManager defaultManager];
        
        [BBSViewManager updateButton:button
                             bgColor:[UIColor clearColor]
                             bgImage:[imageManager optionButtonBGImage]
                               image:nil
                                font:[fontManager bbsOptionTitleFont]
                          titleColor:[UIColor whiteColor]
                               title:title
                            forState:UIControlStateNormal];
        
    }
}

- (void)updateBGImageWithView:(UIView *)view showAbovePoint:(CGPoint )point
{
    if (point.x < view.center.x) {
        [self.bgImageView setImage:[[BBSImageManager defaultManager] optionLeftBGImage]];
    }else{
        [self.bgImageView setImage:[[BBSImageManager defaultManager] optionRightBGImage]];
    }
}

#define ANIMATION_TIME 0.5

- (void)showInView:(UIView *)view showAbovePoint:(CGPoint )point animated:(BOOL)animated
{
    [self updateFrameWithSuperView:view
                    showAbovePoint:point];
    [self updateBGImageWithView:view
                 showAbovePoint:point];
    
    [self updateButtons];
    [self showInView:view animated:animated];
}

@end
