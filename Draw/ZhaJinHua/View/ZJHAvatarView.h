//
//  ZJHAvatarView.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <Foundation/Foundation.h>
#import "DiceAvatarView.h"
#import "HKGirlFontLabel.h"

@class ZJHAvatarView;

@protocol ZJHAvatarViewDelegate <NSObject>

@optional
- (void)didClickOnAvatar:(ZJHAvatarView*)view;
- (void)reciprocalEnd:(ZJHAvatarView*)view;
//- (void)coinDidRaiseUp:(DiceAvatarView*)view;

@end

@interface ZJHAvatarView : NSObject

@property (retain, nonatomic) DiceAvatarView* roundAvatar;
@property (retain, nonatomic) UIImageView*    backgroundImageView;
@property (retain, nonatomic) HKGirlFontLabel*  nickNameLabel;
@property (assign, nonatomic) id<ZJHAvatarViewDelegate> delegate;


@end
