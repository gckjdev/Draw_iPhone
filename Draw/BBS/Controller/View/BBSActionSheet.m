//
//  BBSActionSheet.m
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import "BBSActionSheet.h"
#import "BBSViewManager.h"

#define ISIPAD [DeviceDetection isIPAD]

#define SPACE_LEFTRIGHT_BUTTON (ISIPAD ? 18*2 : 18)
#define SPACE_TOPBOTTOM_BUTTON (ISIPAD ? 12*2 : 12)

#define SPACE_BUTTON_BUTTON (ISIPAD ? 10*2 : 10)

#define BUTTON_SIZE (ISIPAD ? CGSizeMake(120,56) : CGSizeMake(60,28))

@interface BBSActionSheet()
{
    NSArray *_titles;
}
@property(nonatomic, retain)NSArray *titles;
@property(nonatomic, assign)id<BBSActionSheetDelegate> delegate;


@end

@implementation BBSActionSheet


- (id)initWithTitles:(NSArray *)titles
            delegate:(id<BBSActionSheetDelegate>)delegate;
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

- (void)updateFrameWithSuperView:(UIView *)view showAtPoint:(CGPoint )point
{
    NSInteger count = [_titles count];
    CGFloat width = BUTTON_SIZE.width + SPACE_LEFTRIGHT_BUTTON * 2;
    
    CGFloat height = BUTTON_SIZE.height * count;
    height += SPACE_BUTTON_BUTTON * (count - 1);
    height += 2 * SPACE_TOPBOTTOM_BUTTON;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.center = point;
}
- (void)updateButtons
{
    NSInteger i = 0;
    for(NSString *title in _titles){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [button setBackgroundImage:[[BBSImageManager defaultManager] optionButtonBGImage]
        //                          forState:UIControlStateNormal];
        CGFloat y = SPACE_TOPBOTTOM_BUTTON + i *(SPACE_BUTTON_BUTTON + BUTTON_SIZE.height);
        CGFloat x = SPACE_LEFTRIGHT_BUTTON; 
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

- (void)updateBGImageWithView:(UIView *)view showAtPoint:(CGPoint )point
{
    UIImageView *bgImage = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
    [self addSubview:bgImage];
    [bgImage setImage:[[BBSImageManager defaultManager] bbsActionSheetBG]];
}

#define ANIMATION_TIME 0.5

- (void)showInView:(UIView *)view showAtPoint:(CGPoint )point animated:(BOOL)animated
{
    [view addSubview:self];
    [self updateFrameWithSuperView:view showAtPoint:point];
    [self updateBGImageWithView:view
                 showAtPoint:point];
    
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
