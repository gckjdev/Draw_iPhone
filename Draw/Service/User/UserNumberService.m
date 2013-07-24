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

@implementation UserNumberService

static UserNumberService* _defaultUserService;

+ (UserNumberService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserNumberService alloc] init];
    
    return _defaultUserService;
}

- (void)getAndRegisterNumber:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getAndRegisterNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, nil);
        return;
    }
    
    dispatch_async(workingQueue, ^{

        NSDictionary* para = @{ PARA_REMOVE_OLD_NUMBER : @(0),
                                PARA_SET_USER_NUMBER : @(1) };

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

- (void)getOneNumber:(UserNumberServiceResultBlock)block
{
    if ([[UserManager defaultManager] hasXiaojiNumber]){
        PPDebug(@"<getOneNumber> user already has xiaoji number, skip");
        EXECUTE_BLOCK(block, 0, nil);        
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary* para = @{ PARA_REMOVE_OLD_NUMBER : @(1),
                                PARA_SET_USER_NUMBER : @(0) };
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_GET_NEW_NUMBER
                                                                             parameters:para
                                                                          isReturnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* number = [output.jsonDataDict objectForKey:PARA_XIAOJI_NUMBER];
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
        
    });
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

- (void)loginUser:(NSString*)number password:(NSString*)password block:(UserNumberServiceResultBlock)block
{
    
    if ([number length] == 0 || [password length] == 0){
        EXECUTE_BLOCK(block, ERROR_XIAOJI_NUMBER_NULL, nil);
        return;
    }
    
    NSString* encodePassword = [password encodeMD5Base64:PASSWORD_KEY];
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
                    [[UserManager defaultManager] storeUserData:user];
                }
                else{
                    output.resultCode = ERROR_USER_DATA_NULL;
                }
            }
            
            EXECUTE_BLOCK(block, output.resultCode, number);
        });
    });
}


@end
