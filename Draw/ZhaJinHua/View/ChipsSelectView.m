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

#define CHIP_GAP ([DeviceDetection isIPAD] ? 10 : 5)
#define CHIP_Y_OFFSET ([DeviceDetection isIPAD] ? 6 : 3)
#define CHIPS_COUNT 4


#define CHIPS_SELECT_VIEW_WIDTH ([DeviceDetection isIPAD] ? 308 : 154) 
#define CHIPS_SELECT_VIEW_HEIGHT ([DeviceDetection isIPAD] ? 94 : 47)

@interface ChipsSelectView()

@property (assign, nonatomic) id<ChipsSelectViewProtocol> delegate;

@end

@implementation ChipsSelectView
@synthesize delegate = _delegate;


- (void)dealloc
{
    [super dealloc];
}

+ (ChipsSelectView *)createChipsSelectView:(id<ChipsSelectViewProtocol>)delegate

{
    ChipsSelectView *chipsSelectView = [[[ChipsSelectView alloc] initWithFrame:CGRectMake(0, 0, CHIPS_SELECT_VIEW_WIDTH, CHIPS_SELECT_VIEW_HEIGHT)] autorelease];
//    PPDebug(@"%f, %f", chipsSelectView.frame.size.width , chipsSelectView.frame.size.height);
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
        frame = CGRectMake(i++ * (CHIP_VIEW_WIDTH + CHIP_GAP) + CHIP_GAP, CHIP_Y_OFFSET, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
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
