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

- (void)dealToDestinationPoints:(CGPoint[])points
                          count:(int)pointsCount
                          times:(int)times
{
    int i = 0;
    while (pointsCount --) {
        CALayer* layer= [CALayer layer];
        UIImage* back = [[ZJHImageManager defaultManager] pokerBackImage];
        layer.contents = (id)back;
        layer.bounds = CGRectMake(0, 0, back.size.width, back.size.height);
        [self.layer addSublayer:layer];
        
        CAAnimation* anim = [AnimationManager translationAnimationFrom:CGPointMake(self.frame.size.width/2, 0) to:CGPointMake(self.frame.size.width, self.frame.size.height) duration:0.5];
//        if (YES) {
//            [CATransaction setCompletionBlock:^{
//                [layer removeFromSuperlayer];
//            }];
//        }
        
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
