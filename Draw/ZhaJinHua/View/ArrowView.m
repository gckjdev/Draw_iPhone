//
//  ArrowView.m
//  Draw
//
//  Created by 王 小涛 on 12-12-3.
//
//

#import "ArrowView.h"
#import "AnimationManager.h"
#import "ZJHImageManager.h"

@implementation ArrowView


+ (UIButton *)arrowWithCenter:(CGPoint)center
{
    UIButton *bomb = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, ARROW_BUTTON_WIDTH, ARROW_BUTTON_HEIGHT)] autorelease];
    [bomb setBackgroundImage:[[ZJHImageManager defaultManager] bombImage] forState:UIControlStateNormal];
    bomb.center = center;
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:bomb.bounds] autorelease];
    imageView.image = [[ZJHImageManager defaultManager] bombImageLight];
    imageView.userInteractionEnabled = NO;
    [bomb addSubview:imageView];
    
    CGFloat originY = bomb.layer.position.y - ([DeviceDetection isIPAD] ? 20 : 10);
    CGFloat toY = bomb.layer.position.y;
    
    CAAnimation *moveVerticalAni = [AnimationManager moveVerticalAnimationFrom:originY to:toY duration:1.0];
    moveVerticalAni.repeatCount = 1000;
    [bomb.layer addAnimation:moveVerticalAni forKey:nil];
    
    CAAnimation *appearAni = [AnimationManager appearAnimationFrom:0 to:1 duration:1.0];
    appearAni.repeatCount = 1000;
    [imageView.layer addAnimation:appearAni forKey:nil];
    return bomb;
}

@end
