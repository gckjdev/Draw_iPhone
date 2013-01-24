//
//  OpusCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "OpusCell.h"
#import "UIImageView+WebCache.h"

#define OPUS_IMAGE_VIEW_TAG_OFFSET 300
#define OPUS_BUTTON_TAG_OFFSET 400

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
    return 76;
}

- (void)setCellData:(NSArray *)opuses
{
    self.opuses = opuses;
    
    int index = 0;
    for (; index < [opuses count] && index < EACH_CELL_OPUSES_COUNT; index++) {
        DrawFeed *feed = [opuses objectAtIndex:index];
        [[self opusImageView:index] setImageWithURL:[NSURL URLWithString:feed.drawImageUrl]];
        
        [[self opusButton:index] setHidden:NO];
        [[self opusButton:index] addTarget:self action:@selector(clickOpus:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (; index < EACH_CELL_OPUSES_COUNT; index++) {
        [[self opusButton:index] setHidden:YES];
    }
}

- (UIImageView *)opusImageView:(int)index
{
    UIView *view = [self viewWithTag:(OPUS_IMAGE_VIEW_TAG_OFFSET + index)];
    if ([view isKindOfClass:[UIImageView class]]) {
        return (UIImageView *)view;
    }
    return  nil;
}

- (UIButton *)opusButton:(int)index
{
    UIView *view = [self viewWithTag:(OPUS_BUTTON_TAG_OFFSET + index)];
    if ([view isKindOfClass:[UIButton class]]) {
        return (UIButton *)view;
    }
    return  nil;
}

- (void)clickOpus:(id)sender
{
    UIButton *opusButton = (UIButton *)sender;
    int index = opusButton.tag - OPUS_BUTTON_TAG_OFFSET;
    
    if (index < 0 || index >= EACH_CELL_OPUSES_COUNT) {
        return;
    }
    
    DrawFeed *opus = [_opuses objectAtIndex:index];
    if ([delegate respondsToSelector:@selector(didClickOpus:)]) {
        [delegate didClickOpus:opus];
    }
}


@end
