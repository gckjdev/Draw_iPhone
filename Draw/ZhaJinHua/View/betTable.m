//
//  betTable.m
//  Draw
//
//  Created by Kira on 12-10-30.
//
//

#import "BetTable.h"

@implementation BetTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGPoint)getPointByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionRight: 
            return CGPointMake(self.frame.size.width, self.frame.size.height);
        case UserPositionRightTop: 
            return CGPointMake(self.frame.size.width, 0);
        case UserPositionLeft: 
            return CGPointMake(0, self.frame.size.height);
        case UserPositionLeftTop: 
            return CGPointMake(0, 0);
        case UserPositionCenter:
            return CGPointMake(self.frame.size.width/2, self.frame.size.height);
        default:
            return CGPointMake(self.frame.size.width/2, 0);
            break;
    };
    
}

- (void)someBetFrom:(UserPosition)position
           forCount:(int)counter
{
    
}

- (void)clearAllCounter
{
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
