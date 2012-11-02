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

#define CHIP_GAP 5
#define CHIPS_COUNT 4

@interface ChipsSelectView()

@property (assign, nonatomic) id<ChipsSelectViewProtocol> delegate;
@property (retain, nonatomic) CMPopTipView *popupView;

@end

@implementation ChipsSelectView

+ (void)popupAtView:(UIView *)atView
             inView:(UIView *)inView
          aboveView:(UIView *)aboveView
           delegate:(id<ChipsSelectViewProtocol>)delegate
{
    ChipsSelectView *chipsSelectView = [ChipsSelectView createChipsSelectView:delegate];

    [chipsSelectView.popupView presentPointingAtView:atView inView:inView aboveView:aboveView animated:YES pointDirection:PointDirectionAuto];
    
    [chipsSelectView.popupView performSelector:@selector(dismissAnimated:)
                                    withObject:[NSNumber numberWithBool:YES]
                                    afterDelay:3.0];
}

+ (ChipsSelectView *)createChipsSelectView:(id<ChipsSelectViewProtocol>)delegate

{
    ChipsSelectView *chipsSelectView = [[[ChipsSelectView alloc] initWithFrame:CGRectMake(0, 0, CHIP_VIEW_WIDTH * CHIPS_COUNT + CHIP_GAP * (CHIPS_COUNT - 1), CHIP_VIEW_HEIGHT)] autorelease];
    chipsSelectView.delegate = delegate;
    [chipsSelectView addChipViews];
    
    return chipsSelectView;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        imageView.image = [[ZJHImageManager defaultManager] chipsSelectViewBgImage];
        [self addSubview:imageView];
        
        self.popupView = [[[CMPopTipView alloc] initWithCustomView:self needBubblePath:NO] autorelease];
        self.popupView.backgroundColor = [UIColor grayColor];
        self.popupView.alpha = 0.1;
    }
    
    return self;
}

- (void)addChipViews
{
    int i = 0;
    CGRect frame = CGRectMake(0, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
    NSArray *chipValues = [NSArray arrayWithObjects:[NSNumber numberWithInt:5], [NSNumber numberWithInt:10], [NSNumber numberWithInt:25], [NSNumber numberWithInt:50], nil];
    for (NSNumber *chipValue in chipValues) {
        frame = CGRectMake(i++ * (CHIP_VIEW_WIDTH + CHIP_GAP), 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
        ChipView *chipView = [ChipView chipViewWithFrame:frame chipValue:chipValue.intValue delegate:self];
        [self addSubview:chipView];
    }
}

- (void)didClickChipView:(ChipView *)chipView
{
    [self.popupView dismissAnimated:YES];
    if ([_delegate respondsToSelector:@selector(didSelectChip:)]) {
        [_delegate didSelectChip:chipView.chipValue];
    }
}

@end
