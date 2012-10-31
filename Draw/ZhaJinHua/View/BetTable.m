//
//  BetTable.m
//  Draw
//
//  Created by Kira on 12-10-31.
//
//


#import "BetTable.h"
#import "ZJHImageManager.h"
#import "AnimationManager.h"


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

- (CGPoint)getRandomCenterPoint
{
    int randomX = random()%((int)self.frame.size.width/2);
    int randomY = random()%((int)self.frame.size.height/2);
    return CGPointMake(self.frame.size.width/4+randomX, self.frame.size.height/4+randomY);
}

- (void)someBetFrom:(UserPosition)position
           forCount:(int)counter
{
    CALayer* layer = [CALayer layer];
    UIImage* counterImage = [[ZJHImageManager defaultManager] counterImageForCounter:counter];
    [layer setContents:(id)[counterImage CGImage]];
//    UIImageView* counterView = [[[UIImageView alloc] initWithImage:counterImage] autorelease];
    layer.bounds = CGRectMake(0, 0, counterImage.size.width,counterImage.size.height);
    
    [self.layer addSublayer:layer];
    CAAnimation* anim = [AnimationManager translationAnimationFrom:[self getPointByPosition:position]
                                                                to:[self getRandomCenterPoint]
                                                          duration:1
                                                          delegate:self
                                                  removeCompeleted:NO];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:anim forKey:nil];
}

- (void)clearAllCounter
{
    
    for (CALayer* layer in [self.layer sublayers]) {
        CAAnimation* anim = [AnimationManager translationAnimationTo:[self getPointByPosition:UserPositionCenter] duration:1];
        CAAnimation* anim2 = [AnimationManager missingAnimationWithDuration:1];
        anim.removedOnCompletion = NO;
        anim2.removedOnCompletion = NO;
        anim.delegate = self;
        [layer addAnimation:anim2 forKey:nil];
        [layer addAnimation:anim forKey:nil];
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

