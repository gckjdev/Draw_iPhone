//
//  OpusCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "OpusCell.h"
#import "UIButton+WebCache.h"
#import "UIViewUtils.h"


#define OPUS_BUTTON_TAG_OFFSET 200

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

- (void)setCellData:(NSArray *)opuses
{
    [self removeAllSubviews];
    
    self.opuses = opuses;
    
    for (int index=0; index<[opuses count] && index<MAX_OPUSES_EACH_CELL; index++)
    {
        DrawFeed *feed = [opuses objectAtIndex:index];
        PPDebug(@"%@", feed.drawImageUrl);
        [[self opusButtonOfIndex:index] setImageWithURL:[NSURL URLWithString:feed.drawImageUrl]];
        [[self opusButtonOfIndex:index] addTarget:self action:@selector(clickOpus:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UIButton *)opusButtonOfIndex:(int)index
{
    return (UIButton *)[self viewWithTag:(OPUS_BUTTON_TAG_OFFSET + index)];
}

- (void)clickOpus:(id)sender
{
    int index = ((UIButton *)sender).tag - OPUS_BUTTON_TAG_OFFSET;
    DrawFeed *opus = [_opuses objectAtIndex:index];
    if ([delegate respondsToSelector:@selector(didClickOpus:)]) {
        [delegate didClickOpus:opus];
    }
}

@end
