//
//  OpusCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "OpusCell.h"
#import "UIImageView+WebCache.h"
#import "UIViewUtils.h"

@interface OpusCell ()

@property (retain, nonatomic) NSArray *opuses;

@end

@implementation OpusCell

- (void)dealloc
{
    [_opuses release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier
{
    return @"OpusCell";
}

+ (CGFloat)getCellHeight
{
    return OPUS_VIEW_HEIGHT;
}

- (void)setCellData:(NSArray *)opuses delegate:(id<OpusViewProtocol>)aDelegate
{
    [self removeAllSubviews];
    
    self.opuses = opuses;
    
    int index = 0;
    for (; index < [opuses count] && index < EACH_CELL_OPUSES_COUNT; index++) {
        DrawFeed *feed = [opuses objectAtIndex:index];

        OpusView *opusView = [OpusView createView];
        opusView.delegate = aDelegate;
        opusView.frame = [self opusViewFrame:index];
        [opusView setDrawFeed:feed];
        
        [self addSubview:opusView];
    }
}

- (CGRect)opusViewFrame:(int)index
{
    CGRect rect = CGRectMake(index * OPUS_VIEW_WIDTH, 0, OPUS_VIEW_WIDTH, OPUS_VIEW_HEIGHT);
    return rect;
}


@end
