//
//  FrameCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-28.
//
//

#import "FrameCell.h"
#import "FrameManager.h"
#import "UIButton+WebCache.h"
#import "UIViewUtils.h"

#define FRAME_BUTTON_TAG_OFFSET 200

@interface FrameCell()

@property (retain, nonatomic) NSArray *frames;

@end


@implementation FrameCell

+ (NSString*)getCellIdentifier
{
    return @"FrameCell";
}

+ (CGFloat)getCellHeight
{
    return 86;
}

- (void)setCellData:(NSArray *)frames
{
    [self removeAllSubviews];
    
    self.frames = frames;
    
    for (int index=0; index<[frames count] && index<MAX_FRAMES_EACH_CELL; index++)
    {
        PBFrame *frame = [frames objectAtIndex:index];
        PPDebug(@"%@", frame.imageUrl);
        [[self frameButtonOfIndex:index] setImageWithURL:[NSURL URLWithString:frame.imageUrl]];
        [[self frameButtonOfIndex:index] addTarget:self action:@selector(clickFrame:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UIButton *)frameButtonOfIndex:(int)index
{
    return (UIButton *)[self viewWithTag:(FRAME_BUTTON_TAG_OFFSET + index)];
}

- (void)clickFrame:(id)sender
{
    int index = ((UIButton *)sender).tag - FRAME_BUTTON_TAG_OFFSET;
    PBFrame *frame = [_frames objectAtIndex:index];
    if ([delegate respondsToSelector:@selector(didClickFrame:)]) {
        [delegate didClickFrame:frame];
    }
}

@end
