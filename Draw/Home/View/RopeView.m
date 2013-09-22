//
//  RopeView.m
//  Draw
//
//  Created by Gamy on 13-9-17.
//
//

#import "RopeView.h"

@implementation RopeView

#define SELF_FRAME (!ISIPAD?CGRectMake(0,0,35,100+(ISIPHONE5?10:0)):CGRectMake(0,0,69,200))

#define IMAGE_FRAME (!ISIPAD?CGRectMake(11,0,13,50):CGRectMake(22,0,25,100))

#define ROPE_IMAGE_NAME (ISIPAD?@"draw_home_light_rope@2x.png":@"draw_home_light_rope.png")

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ropeImage = [[UIImageView alloc] initWithFrame:IMAGE_FRAME];
        _ropeImage.contentMode = UIViewContentModeBottom;
        _ropeImage.image = [UIImage imageNamed:ROPE_IMAGE_NAME];
        _ropeImage.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_ropeImage];
        self.backgroundColor = [UIColor clearColor];
//        _ropeImage.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        
        UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)] autorelease];
        pan.delegate = self;
        [self addGestureRecognizer:pan];

        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
        tap.delegate = self;
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)dealloc
{
    PPRelease(_ropeImage);
    RELEASE_BLOCK(_finishHandler);
    [super dealloc];
}

- (void)dismissAndCallBack
{
    [UIView animateWithDuration:0.5 animations:^{
        [self updateHeight:1];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        EXECUTE_BLOCK(self.finishHandler,self);
    }];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
//    [self startAnimation];
    if (tap.state == UIGestureRecognizerStateRecognized) {
        [self dismissAndCallBack];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{

    CGPoint point = [pan locationInView:self];
    if (point.y > CGRectGetHeight(IMAGE_FRAME)&&point.y<CGRectGetHeight(SELF_FRAME)) {
        [_ropeImage updateHeight:point.y];
    }else if(point.y < CGRectGetHeight(IMAGE_FRAME)){
        [_ropeImage setFrame:IMAGE_FRAME];
    }
    if (pan.state == UIGestureRecognizerStateRecognized) {
        [self dismissAndCallBack];
    }

}

- (void)startAnimation
{
    [self finishAnimation];
    _ropeImage.frame = IMAGE_FRAME;
    [UIView animateWithDuration:MAXFLOAT animations:^{
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView setAnimationDuration:1];
        [UIView setAnimationRepeatCount:MAXFLOAT];
        [_ropeImage updateHeight:(CGRectGetHeight(self.bounds)+CGRectGetHeight(_ropeImage.bounds))/2.0];
    }];
}

- (void)finishAnimation
{
    [_ropeImage.layer removeAllAnimations];
}

- (void)reset
{
    self.frame = SELF_FRAME;    
    _ropeImage.frame = IMAGE_FRAME;
    self.hidden = NO;
    [self startAnimation];
}
+ (id)ropeView
{
    RopeView *rope = [[RopeView alloc] initWithFrame:SELF_FRAME];
    [rope reset];
    return [rope autorelease];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self finishAnimation];
    return YES;
}
@end
