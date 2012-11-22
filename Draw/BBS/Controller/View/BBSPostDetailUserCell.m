//
//  BBSPostDetailUserCell.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostDetailUserCell.h"

@implementation BBSPostDetailUserCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_avatar release];
    [_nickName release];
    [super dealloc];
}
@end
