//
//  UserNumberService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "UserNumberService.h"
#import "UserManager.h"
#import "PPGameNetworkRequest.h"
#import "StringUtil.h"
#import "UIDevice+IdentifierAddition.h"
#import "GroupService.h"

#define GET_NUMBER_TYPE_NORMAL      1
#define GET_NUMBER_TYPE_SHAKE       2


@implementation UserNumberService

static UserNumberService* _defaultUserService;

+ (UserNumberService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserNumberService alloc] init];
    
    return _defaultUserService;
}

- (void)registerNewUserNumber:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getAndRegisterNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, [[UserManager defaultManager] xiaojiNumber]);
        return;
    }
    
    NSString* appId = [GameApp appId];
    NSString* deviceToken = [[UserManager defaultManager] deviceToken];
    NSString* deviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceOS = [DeviceDetection deviceOS];
    NSString* deviceName = [UIUtils getUserDeviceName];
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{
                               PARA_DEVICEID : SAFE_STRING(deviceId),
                               PARA_DEVICETOKEN : SAFE_STRING(deviceToken),
                               PARA_COUNTRYCODE : SAFE_STRING([LocaleUtils getCountryCode]),
                               PARA_DEVICEOS : SAFE_STRING(deviceOS),
                               PARA_LANGUAGE : SAFE_STRING([LocaleUtils getLanguageCode]),
                               PARA_DEVICEMODEL : SAFE_STRING([UIDevice currentDevice].model),
                               PARA_DEVICETYPE : @(DEVICE_TYPE_IOS),
                               PARA_NICKNAME : SAFE_STRING(deviceName)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponsePB:METHOD_REGISTER_NEW_USER_NUMBER
                                                                           parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString* number = nil;
            
            if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){
                [[UserService defaultService] createLocalUserAccount:output.responseData appId:appId];
                number = [[UserManager defaultManager] xiaojiNumber];
                
                // set default home style
                [[UserManager defaultManager] setHomeStyle:[PPConfigManager defaultHomeStyleNewUser]];
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
            
        });
        
    });
}


- (void)getAndRegisterNumber:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getAndRegisterNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, [[UserManager defaultManager] xiaojiNumber]);
        return;
    }
    
    int type = [[UserManager defaultManager] isOldUserWithoutXiaoji] ? GET_NUMBER_TYPE_SHAKE : GET_NUMBER_TYPE_NORMAL;
    
    dispatch_async(workingQueue, ^{

        NSDictionary* para = @{ PARA_REMOVE_OLD_NUMBER : @(0),
                                PARA_SET_USER_NUMBER : @(1),
                                PARA_TYPE : @(type)};

        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
                                                                             parameters:para
                                                                          isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
            if (output.resultCode == 0){
                // save number
                [[UserManager defaultManager] setXiaojiNumber:number];
                [[UserManager defaultManager] storeUserData];
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
            
        });
        
    });
}


- (void)getOneNumber:(int)type block:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getOneNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_REMOVE_OLD_NUMBER : @(1),
                                PARA_SET_USER_NUMBER : @(0),
                                PARA_TYPE : @(type) };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
        
    });
}

- (void)shakeOneNumber:(UserNumberServiceResultBlock)block
{
//    [self getOneNumber:GET_NUMBER_TYPE_SHAKE block:block];
    
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<shakeOneNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{
                                PARA_GAME_ID : DRAW_GAME_ID,            // hard code to draw here
                                PARA_APPID : DRAW_APP_ID,               // hard code to draw here
                                PARA_REMOVE_OLD_NUMBER : @(1),
                                PARA_SET_USER_NUMBER : @(0),
                                PARA_TYPE : @(GET_NUMBER_TYPE_SHAKE) };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
        
    });
    
}

- (void)getOneNumber:(UserNumberServiceResultBlock)block
{
    [self getOneNumber:GET_NUMBER_TYPE_NORMAL block:block];
    
//    if ([[UserManager defaultManager] hasXiaojiNumber]){
//        PPDebug(@"<getOneNumber> user already has xiaoji number, skip");
//        EXECUTE_BLOCK(block, 0, nil);        
//        return;
//    }
//    
//    dispatch_async(workingQueue, ^{
//        
//        NSDictionary* para = @{ PARA_REMOVE_OLD_NUMBER : @(1),
//                                PARA_SET_USER_NUMBER : @(0) };
//        
//        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
//                                                                             parameters:para
//                                                                          isReturnArray:NO];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
//            EXECUTE_BLOCK(block, output.resultCode, number);
//        });
//        
//    });
}

- (void)takeUserNumber:(NSString*)number block:(UserNumberServiceResultBlock)block
{
    
    if ([number length] == 0){
        EXECUTE_BLOCK(block, ERROR_XIAOJI_NUMBER_NULL, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_XIAOJI_NUMBER : number,
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_SET_USER_NUMBER
                                                                             parameters:para
                                                                          isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == 0){
                // save number
                [[UserManager defaultManager] setXiaojiNumber:number];
                [[UserManager defaultManager] storeUserData];            
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
        
    });
}

- (void)setUserXiaoji:(NSString*)userId xiaoji:(NSString*)number block:(UserNumberServiceResultBlock)block
{
    if ([number length] == 0 || [userId length] == 0){
        EXECUTE_BLOCK(block, ERROR_XIAOJI_NUMBER_NULL, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_XIAOJI_NUMBER : number,
                                PARA_USERID : userId
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_SET_USER_NUMBER
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == 0){
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
        
    });
}


- (void)loginUser:(NSString*)number encodedPassword:(NSString*)password block:(UserNumberServiceResultBlock)block
{
    if ([number length] == 0 || [password length] == 0){
        EXECUTE_BLOCK(block, ERROR_XIAOJI_NUMBER_NULL, nil);
        return;
    }
    NSString* encodePassword = password;    
    NSString* deviceModel = [[UIDevice currentDevice] model];
    NSString* deviceOS = [DeviceDetection deviceOS];
    NSString* newDeviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceToken = [[[UserManager defaultManager] pbUser] deviceToken];
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_XIAOJI_NUMBER : number,
                                PARA_PASSWORD : encodePassword,
                                PARA_DEVICEMODEL : (deviceModel == nil) ? @"" : deviceModel,
                                PARA_DEVICEID : (newDeviceId == nil) ? @"" : newDeviceId,
                                PARA_DEVICETYPE : STRING_DEVICE_TYPE_IOS,
                                PARA_DEVICETOKEN : (deviceToken == nil) ? @"" : deviceToken,
                                PARA_DEVICEOS : (deviceOS == nil) ? @"" : deviceOS
                                };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponsePB:METHOD_LOGIN_NUMBER
                                                                         parameters:para];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (output.resultCode == 0){
                PBGameUser* user = [output.pbResponse user];
                if (user != nil){
                                        
                    [[UserService defaultService] createLocalUserAccount:user];                    
                    [UserManager addUserToHistoryList:user];
                    
                    [[GroupService defaultService] syncGroupRoles];
                    [[GroupService defaultService] syncFollowGroupIds];
                    [[GroupService defaultService] syncFollowTopicIds];
                    
                }
                else{
                    output.resultCode = ERROR_USER_DATA_NULL;
                }
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
    });

}

- (void)loginUser:(NSString*)number password:(NSString*)password block:(UserNumberServiceResultBlock)block
{    
    if ([number length] == 0 || [password length] == 0){
        EXECUTE_BLOCK(block, ERROR_XIAOJI_NUMBER_NULL, nil);
        return;
    }
    NSString* encodePassword = [password encodeMD5Base64:PASSWORD_KEY];
    [self loginUser:number encodedPassword:encodePassword block:block];
}

- (void)askForLogout
{
    
}

@end
