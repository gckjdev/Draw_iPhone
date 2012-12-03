//
//  BBSPopupSelectionView.m
//  Draw
//
//  Created by gamy on 12-11-30.
//
//

#import "BBSPopupSelectionView.h"
#import "BBSViewManager.h"

#define ISIPAD [DeviceDetection isIPAD]

#define SPACE_TOP_BUTTON (ISIPAD ? 7*2 : 7)
#define SPACE_BOTTOM_BUTTON (ISIPAD ? 15*2 : 15)
#define SPACE_LEFTRIGHT_BUTTON (ISIPAD ? 8*2 : 8)
#define SPACE_BUTTON_BUTTON (ISIPAD ? 7*2 : 7)

#define SPACE_LEFTRIGHT_TIP (ISIPAD ? 30*2 : 30)

#define BUTTON_SIZE (ISIPAD ? CGSizeMake(82,43) : CGSizeMake(41,22))

@interface BBSPopupSelectionView ()
{
    NSArray *_titles;
}
@property(nonatomic, retain)NSArray *titles;
@property(nonatomic, assign)id<BBSPopupSelectionViewDelegate>delegate;

@end

@implementation BBSPopupSelectionView

- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSPopupSelectionViewDelegate>)delegate;
{
    self = [super init];
    if (self) {
        self.titles = titles;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_titles);
    [super dealloc];
}


- (void)updateFrameWithSuperView:(UIView *)view showAbovePoint:(CGPoint )point
{
    NSInteger count = [_titles count];
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
    self.frame = CGRectMake(x, y, width, height);
}
- (void)updateButtons
{
    NSInteger i = 0;
    for(NSString *title in _titles){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setBackgroundImage:[[BBSImageManager defaultManager] optionButtonBGImage]
//                          forState:UIControlStateNormal];
        CGFloat y = SPACE_TOP_BUTTON;
        CGFloat x = SPACE_LEFTRIGHT_BUTTON + i *(SPACE_BUTTON_BUTTON + BUTTON_SIZE.width);
        button.frame = CGRectMake(x, y, BUTTON_SIZE.width, BUTTON_SIZE.height);
        button.tag = i;
        [button addTarget:self
                   action:@selector(clickButton:)
         forControlEvents:UIControlEventTouchUpInside];
        
        ++i;
        [self addSubview:button];
        
        
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
    UIImageView *bgImage = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    [self addSubview:bgImage];
    if (point.x < view.center.x) {
        [bgImage setImage:[[BBSImageManager defaultManager] optionLeftBGImage]];
    }else{
        [bgImage setImage:[[BBSImageManager defaultManager] optionRightBGImage]];
    }
}

#define ANIMATION_TIME 0.5

- (void)showInView:(UIView *)view showAbovePoint:(CGPoint )point animated:(BOOL)animated
{
    [view addSubview:self];
    [self updateFrameWithSuperView:view
                    showAbovePoint:point];
    [self updateBGImageWithView:view
                 showAbovePoint:point];
    
    [self updateButtons];
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:ANIMATION_TIME animations:^{
            self.alpha = 1;
        }];
    }
}

- (void)clickButton:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionView:didSelectedButtonIndex:)]) {
        [self.delegate selectionView:self didSelectedButtonIndex:button.tag];
    }
    self.alpha = 1;
    [UIView animateWithDuration:ANIMATION_TIME animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
