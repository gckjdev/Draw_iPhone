//
//  ChipsSelectView.m
//  Draw
//
//  Created by 王 小涛 on 12-11-1.
//
//

#import "ChipsSelectView.h"
#import "CMPopTipView.h"
#import "ZJHImageManager.h"
#import "ChipView.h"

@implementation ChipsSelectView

+ (void)popupAtView:(UIView *)atView
             inView:(UIView *)inView
          aboveView:(UIView *)aboveView
{
    ChipsSelectView *chipsSelectView = [ChipsSelectView createChipsSelectView];
    CMPopTipView *popupView = [[[CMPopTipView alloc] initWithCustomView:chipsSelectView needBubblePath:NO] autorelease];
    [popupView presentPointingAtView:atView inView:inView aboveView:aboveView animated:YES pointDirection:PointDirectionAuto];
}

+ (ChipsSelectView *)createChipsSelectView
{
    return [[[ChipsSelectView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)] autorelease];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.image = [[ZJHImageManager defaultManager] chipsSelectViewBgImage];
        [self addSubview:imageView];
        
        [self addChipViews];
    }
    
    return self;
}

- (void)addChipViews
{
    int i = 0;
    CGRect frame = CGRectMake(0, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
    NSArray *chipValues = [NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], nil];
    for (NSNumber *chipValue in chipValues) {
        frame = CGRectMake(i * CHIP_VIEW_WIDTH, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
        ChipView *chipView = [ChipView chipViewWithFrame:frame chipValue:5 delegate:self];
        [self addSubview:chipView];
    }
}

@end
