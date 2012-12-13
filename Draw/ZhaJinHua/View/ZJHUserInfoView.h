//
//  ZJHUserInfoView.h
//  Draw
//
//  Created by Kira on 12-12-4.
//
//

#import "DiceUserInfoView.h"
#import "CommonUserInfoView.h"

@interface ZJHUserInfoView : CommonUserInfoView

+ (void)showFriend:(MyFriend*)afriend
        infoInView:(PPViewController*)superController
        needUpdate:(BOOL)needUpdate
           canChat:(BOOL)canChat;

@end
