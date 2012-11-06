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
#import "ZJHGameService.h"

#define CHIP_GAP 5
#define CHIPS_COUNT 4

@interface ChipsSelectView()

@property (assign, nonatomic) id<ChipsSelectViewProtocol> delegate;

@end

@implementation ChipsSelectView

- (void)dealloc
{
    [super dealloc];
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
    }
    
    return self;
}

- (void)addChipViews
{
    int i = 0;
    CGRect frame = CGRectMake(0, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
    for (NSNumber *chipValue in [[ZJHGameService defaultService] chipValues]) {
        frame = CGRectMake(i++ * (CHIP_VIEW_WIDTH + CHIP_GAP), 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
        ChipView *chipView = [ChipView chipViewWithFrame:frame chipValue:chipValue.intValue delegate:self];
        
        if (chipValue.intValue <= [[[ZJHGameService defaultService] gameState] singleBet]) {
            chipView.enabled = NO;
            chipView.alpha = 0.5;
        }
        
        [self addSubview:chipView];
    }
}

- (void)didClickChipView:(ChipView *)chipView
{
    if ([_delegate respondsToSelector:@selector(didSelectChip:)]) {
        [_delegate didSelectChip:chipView.chipValue];
    }
}

@end
