//
//  PokerView.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "PokerView.h"

@implementation PokerView

- (void)dealloc {
    [_backImageView release];
    [_fontView release];
    [_rankImageView release];
    [_suitImageView release];
    [_bodyImageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)faceDown:(BOOL)animation
{
    self.backImageView.hidden = NO;
}

- (void)faceUp:(BOOL)animation
{
    if (self.backImageView.hidden == YES) {
        return;
    }
    
    self.backImageView.hidden = YES;
}



@end
