//
//  SuperUserManageAction.h
//  Draw
//
//  Created by Kira on 13-2-18.
//
//

#import <Foundation/Foundation.h>


@interface SuperUserManageAction : NSObject <UIActionSheetDelegate> {
    NSString* _targetUserId;
    NSString* _targetUserNickName;
    int _targetUserCurrentBalance;
    UIViewController* _superController;
}

- (id)initWithTargetUserId:(NSString*)userId
                    nickName:(NSString*)nickName
                     balance:(int)balance;

- (void)showInController:(UIViewController*)controller;

@end
