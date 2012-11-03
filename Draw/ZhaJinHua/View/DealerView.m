//
//  DealerView.m
//  Draw
//
//  Created by Kira on 12-11-1.
//
//

#import "DealerView.h"
#import "ZJHImageManager.h"
#import "AnimationManager.h"
#import "ZJHGameController.h"

@implementation DealerView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGFloat)randomAngle
{
    return ((float)(rand()%100)/100);
}

- (CGPoint)pointByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionRight:
            return CGPointMake(self.frame.size.width, self.frame.size.height);
        case UserPositionRightTop:
            return CGPointMake(self.frame.size.width, self.frame.size.height/2);
        case UserPositionLeft:
            return CGPointMake(0, self.frame.size.height);
        case UserPositionLeftTop:
            return CGPointMake(0, self.frame.size.height/2);
        case UserPositionCenter:
            return CGPointMake(self.frame.size.width/2, self.frame.size.height);
        default:
            return CGPointMake(self.frame.size.width/2, 0);
            break;
    };
}

- (void)dealCard:(id)position
{
    int pos = ((NSNumber*)position).intValue;
    CALayer* layer= [CALayer layer];
    UIImage* back = [[ZJHImageManager defaultManager] pokerBackImage];
    layer.contents = (id)[back CGImage];
    layer.bounds = CGRectMake(0, 0, back.size.width/2, back.size.height/2);
    layer.shouldRasterize = YES;
    [self.layer addSublayer:layer];
    
    CAAnimation* anim = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, 0) to:[self pointByPosition:pos] duration:0.5 delegate:self removeCompeleted:NO];
    float angle = [self randomAngle];
    CAAnimation* anim2 = [AnimationManager rotationAnimationWithRoundCount:angle duration:0.5];
    anim2.removedOnCompletion = NO;
    //        PPDebug(@"deal to point (%.2f, %.2f)",points[i].x, points[i].y );
    PPDebug(@" <test> remain cards = %d", _remainCards);
    if (_remainCards == 1) {
        
        [CATransaction setCompletionBlock:^{
            if (_delegate && [_delegate respondsToSelector:@selector(didDealFinish:)]) {
                [_delegate didDealFinish:self];
                for (CALayer* layer in [self.layer sublayers]) {
                    [layer setOpacity:0];
                }
            }
            PPDebug(@"<test> deal finish!");
        }];
    }
    
    [layer addAnimation:anim forKey:nil];
    [layer addAnimation:anim2 forKey:nil];
    
    _remainCards--;
}

- (void)dealWithPositionArray:(NSArray*)array
                        times:(int)times
{
    float delay = 0;
    _remainCards = times * [array count];
    while (times --) {
        for (NSNumber* position in array) {
            [self performSelector:@selector(dealCard:) withObject:position afterDelay:delay];
            delay = delay + 0.5;
            
        }
        
    }
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
