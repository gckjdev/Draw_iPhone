//
//  DiceAvatarView.h
//  Draw
//
//  Created by Orange on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HJManagedImageV;
@class DACircularProgressView;
@class DiceAvatarView;

typedef enum {
    Square = 1,
    Round = 2,
}AvatarViewStyle;

@protocol DiceAvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(DiceAvatarView*)view;
- (void)reciprocalEnd:(DiceAvatarView*)view;

@end

@interface DiceAvatarView : UIView
{
//    NSInteger _score;
//    UIButton *markButton;
    HJManagedImageV *imageView;
    DACircularProgressView* progressView;
    NSString *_userId;
    UIImageView *bgView;
    float _currentProgress;
    NSTimer* _timer;
    AvatarViewStyle _currentStyle;
    CFTimeInterval _reciprocolTime;
}

//- (void)setUrlString:(NSString *)urlString;
//- (id)initWithUrlString:(NSString *)urlString 
//                 gender:(BOOL)gender 
//                  level:(int)level;
//- (id)initWithUrlString:(NSString *)urlString 
//                  frame:(CGRect)frame 
//                 gender:(BOOL)gender 
//                  level:(int)level;

- (void)setImage:(UIImage *)image;
//- (void)setAvatarFrame:(CGRect)frame;
- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender;
- (void)setProgress:(CGFloat)progress;
- (void)setProgressHidden:(BOOL)hidden;
- (void)setAvatarStyle:(AvatarViewStyle)style;
- (void)startReciprocol:(CFTimeInterval)reciprocolTime;
//- (void)setAvatarSelected:(BOOL)selected;
//- (void)setAvatarSelected:(BOOL)selected level:(int)level;
- (void)setUrlString:(NSString *)urlString 
              userId:(NSString*)userId
              gender:(BOOL)gender 
               level:(int)level 
          drunkPoint:(int)drunkPint 
              wealth:(int)wealth;

@property(nonatomic, assign) NSInteger score;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, assign) id<DiceAvatarViewDelegate> delegate;
@property(nonatomic, assign) BOOL hasPen;

@end
