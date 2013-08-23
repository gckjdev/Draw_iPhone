//
//  DiceAvatarView.h
//  Draw
//
//  Created by Orange on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class HJManagedImageV;
@class DACircularProgressView;
@class DiceAvatarView;

typedef enum {
    AvatarViewStyle_Square = 1,
    AvatarViewStyle_Round = 2,
}AvatarViewStyle;

@protocol DiceAvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(DiceAvatarView*)view;
- (void)reciprocalEnd:(DiceAvatarView*)view;
- (void)coinDidRaiseUp:(DiceAvatarView*)view;

@end

@interface DiceAvatarView : UIView
{
//    NSInteger _score;
//    UIButton *markButton;
    UIImageView *imageView;
    DACircularProgressView* progressView;
    NSString *_userId;
    UIImageView *bgView;
    float _currentProgress;
    NSTimer* _timer;
    AvatarViewStyle _currentStyle;
    CFTimeInterval _reciprocolTime;
    UIView* _rewardView;
    UIImageView* _rewardCoinView;
    UILabel* _rewardCoinLabel;
    UIImage* _originAvatar;
    BOOL _isBlackAndWhite;
    UIImageView* _clockView;
    
}

- (void)setImage:(UIImage *)image;
- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender;
- (void)setCurrentProgress:(CGFloat)progress;
- (void)setProgressBarWidth:(CGFloat)width;
- (void)setProgressHidden:(BOOL)hidden;
- (void)setAvatarStyle:(AvatarViewStyle)style;
- (void)startReciprocol:(CFTimeInterval)reciprocolTime;
- (void)startReciprocol:(CFTimeInterval)reciprocolTime 
           fromProgress:(float)progress;

- (void)setUrlString:(NSString *)urlString 
              userId:(NSString*)userId
              gender:(BOOL)gender 
               level:(int)level 
          drunkPoint:(int)drunkPint 
              wealth:(int)wealth;
- (void)setGrayAvatar:(BOOL)isGray;
- (void)stopReciprocol;
- (void)rewardCoins:(int)coinsCount 
           duration:(float)duration;
- (void)setGestureRecognizerEnable:(BOOL)enable;

- (CGFloat)getCurrentProgress;

- (void)addFlyClockOnMyHead;
- (void)removeFlyClockOnMyHead;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, assign) id<DiceAvatarViewDelegate> delegate;
@property(nonatomic, assign) BOOL hasPen;

@end
