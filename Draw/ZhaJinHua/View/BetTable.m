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
#import "ChipView.h"

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
        _visibleLayerQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _layerQueue = [[NSMutableArray alloc] init];
        _visibleLayerQueue = [[NSMutableArray alloc] init];
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
            return CGPointMake(self.frame.size.width, self.frame.size.height*0.6);
        case UserPositionRightTop:
            return CGPointMake(self.frame.size.width, self.frame.size.height*0.1);
        case UserPositionLeft:
            return CGPointMake(0, self.frame.size.height*0.6);
        case UserPositionLeftTop:
            return CGPointMake(0, self.frame.size.height*0.1);
        case UserPositionCenter:
            return CGPointMake(self.frame.size.width/2, self.frame.size.height);
        default:
            return CGPointMake(self.frame.size.width/2, 0);
            break;
    };
}

- (CGPoint)getRandomCenterPoint
{
    if (_visibleLayerQueue.count < 20) {
        int randomX = random()%((int)self.frame.size.width/4);
        int randomY = random()%((int)self.frame.size.height/4);
        return CGPointMake(self.frame.size.width*0.375+randomX, self.frame.size.height/6+randomY);
    }
    int randomX = random()%((int)self.frame.size.width/2);
    int randomY = random()%((int)self.frame.size.height/2);
    return CGPointMake(self.frame.size.width/4+randomX, self.frame.size.height/8+randomY);
}

- (void)someBetFrom:(UserPosition)position
          chipValue:(int)chipValue
              count:(int)count
{
    while (count--) {
        [self someBetFrom:position chipValue:chipValue];
    };
}

- (void)someBetFrom:(UserPosition)position
          chipValue:(int)chipValue
{
    CALayer* layer = [CALayer layer];
    UIImage* chipImage = [[ZJHImageManager defaultManager] chipImageForChipValue:chipValue];
    [layer setContents:(id)[chipImage CGImage]];
    layer.bounds = CGRectMake(0, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
//    layer.shouldRasterize = YES;
    
    [self.layer addSublayer:layer];
    [_visibleLayerQueue enqueue:layer];

    CGPoint randomPoint = [self getRandomCenterPoint];
    layer.position = randomPoint;
    CAAnimation* anim = [AnimationManager translationAnimationFrom:[self getPointByPosition:position]
                                                                to:randomPoint
                                                          duration:0.5
                                                          delegate:self
                                                  removeCompeleted:NO];
//    [CATransaction setCompletionBlock:^{
//        layer.position = randomPoint;
//    }];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [layer addAnimation:anim forKey:nil];
}

- (void)userWonAllChips:(UserPosition)position
{
    //清除上一次残留的筹码
//    PPDebug(@"<test>clear chips, layerQueue count = %d",_layerQueue.count);
    while ([_layerQueue peek]) {
        CALayer* layer = [_layerQueue dequeue];
        [layer removeFromSuperlayer];
    }
    
    //播放当前筹码动画，把筹码压进清除队列
    while ([_visibleLayerQueue peek] != nil) {
        CALayer* layer = [_visibleLayerQueue dequeue];
        CAAnimation* anim = [AnimationManager translationAnimationFrom:layer.position
                                                                    to:[self getPointByPosition:position]
                                                              duration:0.5
                                                              delegate:self
                                                      removeCompeleted:NO];
        [CATransaction setCompletionBlock:^{
            layer.opacity = 0;
        }];
        [layer addAnimation:anim forKey:nil];
        [_layerQueue enqueue:layer];
//        PPDebug(@"<test>enqueue, count = %d",_layerQueue.count);
    }
}

- (void)clearAllChips
{
    while ([_visibleLayerQueue peek]) {
        [(CALayer*)[_visibleLayerQueue dequeue] removeFromSuperlayer];
    }
    while ([_layerQueue peek]) {
        [(CALayer*)[_visibleLayerQueue dequeue] removeFromSuperlayer];
    }
}


- (void)betSome:(int)totalBet
   minSingleBet:(int)singleBet
{
    int randomCount = totalBet/singleBet;
    while (randomCount --) {
        CALayer* layer = [CALayer layer];
        UIImage* chipImage = [[ZJHImageManager defaultManager] chipImageForChipValue:singleBet];
        [layer setContents:(id)[chipImage CGImage]];
        layer.bounds = CGRectMake(0, 0, CHIP_VIEW_WIDTH, CHIP_VIEW_HEIGHT);
        //    layer.shouldRasterize = YES;
        layer.position = [self getRandomCenterPoint];
        [self.layer addSublayer:layer];
        [_visibleLayerQueue enqueue:layer];
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

