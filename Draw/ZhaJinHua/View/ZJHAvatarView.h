//
//  ZJHAvatarView.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <UIKit/UIKit.h>
#import "DiceAvatarView.h"

@class PBGameUser;
@class ZJHAvatarView;

@protocol ZJHAvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(ZJHAvatarView*)view;
- (void)reciprocalEnd:(ZJHAvatarView*)view;
//- (void)coinDidRaiseUp:(DiceAvatarView*)view;

@end

@interface ZJHAvatarView : UIView <DiceAvatarViewDelegate>

@property (retain, nonatomic) DiceAvatarView* roundAvatar;
@property (retain, nonatomic) IBOutlet UIView* roundAvatarPlaceView;
@property (retain, nonatomic) IBOutlet UIImageView* backgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel*  nickNameLabel;
@property (assign, nonatomic) id<ZJHAvatarViewDelegate> delegate;
@property (retain, nonatomic) PBGameUser* userInfo;

- (void)updateByPBGameUser:(PBGameUser*)user;
- (void)resetAvatar;
- (void)startReciprocal:(CFTimeInterval)reciprocalTime;
- (void)startReciprocal:(CFTimeInterval)reciprocalTime
           fromProgress:(float)progress;

+ (ZJHAvatarView*)createZJHAvatarView;
- (void)addTapGuesture;
- (void)stopReciprocal;

@end
