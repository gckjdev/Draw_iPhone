//
//  LevelService.m
//  Draw
//
//  Created by Orange on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LevelService.h"
#import "PPViewController.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "UserManager.h"
#define KEY_LEVEL           @"USER_KEY_LEVEL"
#define KEY_EXP             @"USER_KEY_EXPERIENCE"
#define MAX_LEVEL           50

const static long levelExpMap[MAX_LEVEL] = {0,60, 180, 360, 600, 900, 1224, 1573, 1950, 2356, 2795, 3269, 3779, 4331, 4925, 5567, 6259, 7007, 7813, 8683, 9621, 10634, 11726, 12905, 14177, 15550, 17031, 18629, 20354, 22214, 24222, 26388, 28725, 31247, 33968, 36904, 40072, 43490, 47178, 51158, 55452, 60086, 65085, 70479, 76300, 82580, 89356, 96668, 104558, 113070};

static LevelService* _defaultLevelService;



@implementation LevelService
@synthesize delegate = _delegate;

+ (LevelService*)defaultService
{
    if (_defaultLevelService == nil)
        _defaultLevelService = [[LevelService alloc] init];
    
    return _defaultLevelService;
}

- (int)level
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_LEVEL];
    if (value) {
        return value.intValue;
    }
    return 0;
}

- (long)experience
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* value = [userDefaults objectForKey:KEY_EXP];
    if (value) {
        return value.longValue;
    }
    return 0;
}

- (void)setLevel:(NSInteger)level
{
    if (level <= 0)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithInt:level] forKey:KEY_LEVEL];    
    [userDefaults synchronize];
}
- (void)setExperience:(float)experience
{
    if (experience <= 0)
        return;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithFloat:experience] forKey:KEY_EXP];    
    [userDefaults synchronize];
}

- (void)addExp:(long)exp
{
    long currentExp = [self experience];
    int newLevel = [self getLevelByExp:(currentExp+exp)];
    [self setExperience:(currentExp+exp)];
    if ([self level] != newLevel) {
        [self setLevel:newLevel];
        if (_delegate && [_delegate respondsToSelector:@selector(levelUp:)]) {
            [_delegate levelUp:newLevel];
        }
    }
}
- (void)minusExp:(long)exp
{
    long currentExp = [self experience];
    int newLevel = [self getLevelByExp:(currentExp+exp)];
    [self setExperience:(currentExp-exp)];
    if ([self level] != newLevel) {
        [self setLevel:newLevel];
        if (_delegate && [_delegate respondsToSelector:@selector(levelDown:)]) {
            [_delegate levelDown:newLevel];
        }
    }
}
- (long)expRequiredForNextLevel
{
    if ([self level]) {
        return [self level];
    }
    return levelExpMap[1];
}

- (int)getLevelByExp:(float)exp
{
    if (exp >= (float)levelExpMap[MAX_LEVEL]) {
        return MAX_LEVEL;
    }
    for (int i = 1; i < MAX_LEVEL; i ++) {
        if (exp >= (float)levelExpMap[i-1] && exp < (float)levelExpMap[i]) {
            return i;
        }
    }
    return 0;
}

- (void)syncExpAndLevel:(PPViewController*)viewController
{
    
    [viewController showActivityWithText:NSLS(@"kRegisteringUser")];    
    dispatch_async(workingQueue, ^{
        
        CommonNetworkOutput* output = nil;        
        output = [GameNetworkRequest syncExpAndLevel:SERVER_URL 
                                               appId:APP_ID 
                                              userId:[UserManager defaultManager].userId 
                                               level:[self level] 
                                                 exp:[self experience]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (output.resultCode == ERROR_SUCCESS) {
                // save return User ID locally
//                NSString* userId = [output.jsonDataDict objectForKey:PARA_USERID]; 
//                NSString* nickName = [UserManager nickNameByEmail:email];
//                
//                // save data                
//                [[UserManager defaultManager] saveUserId:userId 
//                                                   email:email 
//                                                password:password 
//                                                nickName:nickName 
//                                               avatarURL:nil];
//                
//                int balance = [[output.jsonDataDict objectForKey:PARA_ACCOUNT_BALANCE] intValue];
//                [[AccountManager defaultManager] updateBalanceFromServer:balance];
//                
//                if ([viewController respondsToSelector:@selector(didUserRegistered:)]){
//                    [viewController didUserRegistered:output.resultCode];                    
//                }
            }
            else if (output.resultCode == ERROR_NETWORK) {
                //[viewController popupUnhappyMessage:NSLS(@"kSystemFailure") title:nil];
            }
            else if (output.resultCode == ERROR_USERID_NOT_FOUND) {
                // @"对不起，用户注册无法完成，请联系我们的技术支持以便解决问题"
                //[viewController popupUnhappyMessage:NSLS(@"kUnknownRegisterFailure") title:nil];
            }
            else if (output.resultCode == ERROR_EMAIL_EXIST) {
                // @"对不起，该电子邮件已经被注册"
//                [viewController popupUnhappyMessage:NSLS(@"kEmailUsed") title:nil];
//                InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kUserLogin") delegate:viewController];
//                [dialog.targetTextField setPlaceholder:NSLS(@"kEnterPassword")];
//                [dialog showInView:viewController.view];
            }
            else if (output.resultCode == ERROR_EMAIL_NOT_VALID) {
                // @"对不起，该电子邮件格式不正确，请重新输入"
                //[viewController popupUnhappyMessage:NSLS(@"kEmailNotValid") title:nil];
            }
            else {
                // @"对不起，注册失败，请稍候再试"
                //[viewController popupUnhappyMessage:NSLS(@"kGeneralFailure") title:nil];
            }
        });
        
    });
}



@end
