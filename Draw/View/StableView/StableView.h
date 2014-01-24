//
//  StableView.h
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemType.h"


@interface ToolView : UIButton
{
    NSInteger _number;
    UIButton *numberButton;
    UIImageView* alreadyHasFlag;
    ItemType _itemType;
}


@property(nonatomic,assign)ItemType itemType;
@property(nonatomic, assign) BOOL alreadyHas;

- (id)initWithItemType:(ItemType)type number:(NSInteger)number;
- (id)initWithNumber:(NSInteger)number;
- (void)setNumber:(NSInteger)number;
- (NSInteger)number;
- (void)addTarget:(id)target action:(SEL)action;
- (void)decreaseNumber;
- (void)setEnabled:(BOOL)enabled;
- (void)setAlreadyHas:(BOOL)alreadyHas;
+ (CGFloat)width;
+ (CGFloat)height;
+ (ToolView *)tipsViewWithNumber:(NSInteger)number;
+ (ToolView *)flowerViewWithNumber:(NSInteger)number;
+ (ToolView *)tomatoViewWithNumber:(NSInteger)number;

@end

typedef enum {
    Drawer = 1,
    Guesser = 2,
}AvatarType;


@class AvatarView;
@protocol AvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(NSString*)userId;
- (void)didClickOnAvatarView:(AvatarView *)avatarView;

@end

@class BadgeView;

@interface AvatarView : UIView
{
    NSInteger _score;
    UIButton *markButton;
    AvatarType type;
    UIImageView *imageView;
    NSString *_userId;
    UIImageView *bgView;
    UIImageView *_vipFlag;
}


- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender level:(int)level;

- (id)initWithFrame:(CGRect)frame user:(PBGameUser *)user;

- (id)initWithUrlString:(NSString *)urlString frame:(CGRect)frame gender:(BOOL)gender level:(int)level;

- (void)setUrlString:(NSString *)urlString;
- (void)setUser:(PBGameUser *)user;
- (void)setImage:(UIImage *)image;
- (void)setAvatarFrame:(CGRect)frame;
- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender;
- (void)setAvatarUrl:(NSString *)urlString gender:(BOOL)gender useDefaultLogo:(BOOL)useDefaultLogo;
- (void)setAvatarSelected:(BOOL)selected;
- (void)setAvatarSelected:(BOOL)selected level:(int)level;
- (void)setAsSquare;
- (void)setAsRound;
//- (void)setBackgroundImageView:(NSString *)imageName;
- (void)setBackgroundImage:(UIImage *)image;

@property(nonatomic, assign) NSInteger score;
@property(nonatomic, assign) BOOL gender;
@property(nonatomic, retain) NSString *userId;
@property(nonatomic, assign) id<AvatarViewDelegate> delegate;
@property(nonatomic, assign) BOOL hasPen;
@property(nonatomic, assign) CGSize contentInset;
@property(nonatomic, assign) PBGameUser *user;
@property(nonatomic, assign) BOOL isVIP;

- (void)setBadge:(NSInteger)number;
- (BadgeView *)badgeView;
@end


@interface BadgeView : UIButton

+ (id)badgeViewWithNumber:(NSInteger)number;

@property(nonatomic, assign) NSInteger maxNumber; //default is 99
@property(nonatomic, assign) NSInteger number; //default is 99
- (void)setBGImage:(UIImage *)image;

@end
