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

#define MAX_LAYER   10

@implementation BetTable

- (void)dealloc
{
    [_layerQueue release];
    [_visibleLayerQueue release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _layerQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _layerQueue = [[NSMutableArray alloc] init];
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _layerQueue = [[NSMutableArray alloc] init];
        _visibleLayerQueue = [[NSMutableArray alloc] init];
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
    [_visibleLayerQueue enqueue:layer];
    
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
    //清除上一次残留的筹码
    PPDebug(@"<test>clear counter, layerQueue count = %d",_layerQueue.count);
    while ([_layerQueue peek]) {
        CALayer* layer = [_layerQueue dequeue];
        [layer removeFromSuperlayer];
    }
    
    //播放当前筹码动画，把筹码压进清除队列
    while ([_visibleLayerQueue peek] != nil) {
        CALayer* layer = [_visibleLayerQueue dequeue];
        CAAnimation* anim = [AnimationManager translationAnimationTo:[self getPointByPosition:UserPositionCenter] duration:1];
        CAAnimation* anim2 = [AnimationManager missingAnimationWithDuration:1];
        anim.removedOnCompletion = NO;
        anim2.removedOnCompletion = NO;
        [layer addAnimation:anim2 forKey:nil];
        [layer addAnimation:anim forKey:nil];
        [_layerQueue enqueue:layer];
        PPDebug(@"<test>enqueue, count = %d",_layerQueue.count);
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

