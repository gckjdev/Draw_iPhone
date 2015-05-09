//
//  SuperUserManageAction.h
//  Draw
//
//  Created by Kira on 13-2-18.
//
//

#import <Foundation/Foundation.h>

@class PBGameUser;


@interface SuperUserManageAction : NSObject <UIActionSheetDelegate> {
    NSString* _targetUserId;
    NSString* _targetUserNickName;
    int _targetUserCurrentBalance;
    int _targetUserCurrentIngot;
    UIViewController* _superController;
}

@property (nonatomic, retain) PBGameUser* pbUser;

- (id)initWithTargetUserId:(NSString*)userId
                    nickName:(NSString*)nickName
                     balance:(int)balance;
- (id)initWithPBGameUser:(PBGameUser*)pbUser;

- (void)showInController:(UIViewController*)controller;
+ (void)askBlackUser:(NSString*)targetUserId viewController:(UIViewController*)viewController;
+ (BOOL)isInputValid:(NSString*)inputString;
@end
