//
//  PokerView.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <UIKit/UIKit.h>
#import "Poker.h"

@interface PokerView : UIButton

@property (readonly, retain, nonatomic) Poker *poker;
@property (readonly, assign, nonatomic) BOOL isFaceUp;

@property (retain, nonatomic) IBOutlet UIView *frontView;
@property (retain, nonatomic) IBOutlet UIImageView *rankImageView;
@property (retain, nonatomic) IBOutlet UIImageView *suitImageView;
@property (retain, nonatomic) IBOutlet UIImageView *frontBgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *tickImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bodyImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backImageView;

+ (id)createPokerViewWithPoker:(Poker *)poker
                         frame:(CGRect)frame
                      isFaceUp:(BOOL)isFaceUp;

- (void)faceDown:(BOOL)animation;
- (void)faceUp:(BOOL)animation;

- (void)rotateToAngle:(CGFloat)angle animation:(BOOL)animation;
- (void)moveToCenter:(CGPoint)center animation:(BOOL)animation;
- (void)backToOriginPosition:(BOOL)animation;

@end
