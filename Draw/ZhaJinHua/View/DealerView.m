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

- (void)deal
{
    int i = 0;
    int pointsCount = 5;
    CGPoint points[5];
    points[0] = CGPointMake(0, self.frame.size.height/2);
    points[1] = CGPointMake(0, self.frame.size.height);
    points[2] = CGPointMake(self.frame.size.width/2, self.frame.size.height);
    points[3] = CGPointMake(self.frame.size.width, self.frame.size.height);
    points[4] = CGPointMake(self.frame.size.width, self.frame.size.height/2);
    
    
    while (pointsCount --) {
        CALayer* layer= [CALayer layer];
        UIImage* back = [[ZJHImageManager defaultManager] pokerBackImage];
        layer.contents = (id)[back CGImage];
        layer.bounds = CGRectMake(0, 0, back.size.width/2, back.size.height/2);
        layer.shouldRasterize = YES;
        [self.layer addSublayer:layer];
        
        CAAnimation* anim = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, 0) to:points[i++] duration:0.5 delegate:self removeCompeleted:NO];
        float angle = [self randomAngle];
        CAAnimation* anim2 = [AnimationManager rotationAnimationWithRoundCount:angle duration:0.5];
        anim2.removedOnCompletion = NO;
//        PPDebug(@"deal to point (%.2f, %.2f)",points[i].x, points[i].y );
        
        [layer addAnimation:anim forKey:nil];
        [layer addAnimation:anim2 forKey:nil];
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
