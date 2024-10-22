//
//  Draw
//
//  Created by Orange on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class HJManagedImageV;
@class DACircularProgressView;
@class CommonRoundAvatarView;

typedef enum {
    CommonRoundAvatarViewStyle_Square = 1,
    CommonRoundAvatarViewStyle_Round = 2,
}CommonRoundAvatarViewStyle;

@protocol CommonRoundAvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(CommonRoundAvatarView*)view;
- (void)reciprocalEnd:(CommonRoundAvatarView*)view;
- (void)coinDidRaiseUp:(CommonRoundAvatarView*)view;

@end

@interface CommonRoundAvatarView : UIView
{
    UIImageView *imageView;
    DACircularProgressView* progressView;
    NSString *_userId;
    UIImageView *bgView;
    float _currentProgress;
    NSTimer* _timer;
    CommonRoundAvatarViewStyle _currentStyle;
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
//- (void)setProgressBarWidth:(CGFloat)width;
- (void)setProgressHidden:(BOOL)hidden;
- (void)setAvatarStyle:(CommonRoundAvatarViewStyle)style;
- (void)startReciprocol:(CFTimeInterval)reciprocolTime;
- (void)startReciprocol:(CFTimeInterval)reciprocolTime 
           fromProgress:(float)progress;

- (void)setUrlString:(NSString *)urlString 
              userId:(NSString*)userId
              gender:(BOOL)gender 
               level:(int)level 
          drunkPoint:(int)drunkPint 
              wealth:(int)wealth;
//- (void)setGrayAvatar:(BOOL)isGray;
- (void)stopReciprocol;
- (void)rewardCoins:(int)coinsCount 
           duration:(float)duration;
- (void)setGestureRecognizerEnable:(BOOL)enable;

- (CGFloat)getCurrentProgress;

- (void)addFlyClockOnMyHead;
- (void)removeFlyClockOnMyHead;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, assign) id<CommonRoundAvatarViewDelegate> delegate;
@property(nonatomic, assign) BOOL hasPen;

@end
