//
//  BBSActionSheet.m
//  Draw
//
//  Created by gamy on 12-12-3.
//
//

#import "BBSActionSheet.h"
#import "BBSViewManager.h"

//#define ISIPAD [DeviceDetection isIPAD]

#define SPACE_LEFTRIGHT_BUTTON (ISIPAD ? 18*2 : 18)
#define SPACE_TOPBOTTOM_BUTTON (ISIPAD ? 12*2 : 12)

#define SPACE_BUTTON_BUTTON (ISIPAD ? 10*2 : 10)

#define BUTTON_SIZE (ISIPAD ? CGSizeMake(200,60) : CGSizeMake(100,30))


@implementation BBSActionSheet

- (void)dealloc
{
    [super dealloc];
}

- (void)updateFrameWithSuperView:(UIView *)view showAtPoint:(CGPoint )point
{
    NSInteger count = [self.titles count];
    CGFloat width = BUTTON_SIZE.width + SPACE_LEFTRIGHT_BUTTON * 2;
    
    CGFloat height = BUTTON_SIZE.height * count;
    height += SPACE_BUTTON_BUTTON * (count - 1);
    height += 2 * SPACE_TOPBOTTOM_BUTTON;
    
    self.contentView.frame = CGRectMake(0, 0, width, height);
    self.contentView.center = point;
}
- (void)updateButtons
{
    NSInteger i = 0;
    for(NSString *title in self.titles){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [button setBackgroundImage:[[BBSImageManager defaultManager] optionButtonBGImage]
        //                          forState:UIControlStateNormal];
        CGFloat y = SPACE_TOPBOTTOM_BUTTON + i *(SPACE_BUTTON_BUTTON + BUTTON_SIZE.height);
        CGFloat x = SPACE_LEFTRIGHT_BUTTON; 
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


- (void)showInView:(UIView *)view showAtPoint:(CGPoint )point animated:(BOOL)animated
{
//    [view addSubview:self];
    [self updateFrameWithSuperView:view showAtPoint:point];
    [self updateButtons];
    [self.bgImageView setImage:[[BBSImageManager defaultManager] bbsActionSheetBG]];
    [self showInView:view animated:animated];
}




@end
