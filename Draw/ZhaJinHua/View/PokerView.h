//
//  PokerView.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <UIKit/UIKit.h>
#import "Poker.h"



#define FACEUP_ANIMATION_DURATION 0.75
#define FACEDOWN_ANIMATION_DURATION 0.75

#define ROTATE_ANIMATION_DURATION 1
#define MOVE_ANIMATION_DURATION 1


@class PokerView;

@protocol PokerViewProtocol <NSObject>

@optional
- (void)didClickPokerView:(PokerView *)pokerView;
- (void)didClickShowCardButton:(PokerView *)pokerView;
- (void)didClickChangeCardButton:(PokerView *)pokerView;

@end

@interface PokerView : UIView

@property (readonly, assign, nonatomic) id<PokerViewProtocol> delegate;
@property (readonly, retain, nonatomic) Poker *poker;
@property (readonly, assign, nonatomic) BOOL isFaceUp;

@property (retain, nonatomic) IBOutlet UIButton *frontView;
@property (retain, nonatomic) IBOutlet UIImageView *rankImageView;
@property (retain, nonatomic) IBOutlet UIImageView *suitImageView;
@property (retain, nonatomic) IBOutlet UIImageView *frontBgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *tickImageView;
@property (retain, nonatomic) IBOutlet UIImageView *bodyImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backImageView;

+ (id)createPokerViewWithPoker:(Poker *)poker
                         frame:(CGRect)frame
                      delegate:(id<PokerViewProtocol>)delegate;

- (void)enableUserInterface;

- (BOOL)buttonsIsPopup;
- (void)popupButtonsInView:(UIView *)inView;
- (void)dismissButtons;

- (void)faceDown:(BOOL)animation;
- (void)faceUp:(BOOL)animation;

- (void)rotateToAngle:(CGFloat)angle
            animation:(BOOL)animation;
- (void)moveToCenter:(CGPoint)center
           animation:(BOOL)animation;

- (void)backToOriginPosition:(BOOL)animation;

- (void)setShowCardFlag:(BOOL)animation;
- (void)changeToCard:(Poker *)poker animation:(BOOL)animation;

@end
