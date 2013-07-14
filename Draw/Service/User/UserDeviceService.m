//
//  UserDeviceService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-12.
//
//

#import "UserDeviceService.h"
#import "UserManager.h"
#import "PPGameNetworkRequest.h"
#import "DeviceDetection.h"
#import "UIDevice+IdentifierAddition.h"
#import "UserService.h"

@implementation UserDeviceService

static UserDeviceService* _defaultUserService;

+ (UserDeviceService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserDeviceService alloc] init];
    
    return _defaultUserService;
}

- (void)clearUploadDone
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* uploadKey = [NSString stringWithFormat:@"upload_device_user_id_%@", userId];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:uploadKey];
}

- (void)setUploadDone
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* uploadKey = [NSString stringWithFormat:@"upload_device_user_id_%@", userId];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"DONE" forKey:uploadKey];
}


- (BOOL)isUploadDone
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* uploadKey = [NSString stringWithFormat:@"upload_device_user_id_%@", userId];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:uploadKey] == nil){
        return NO;
    }

    // check device ID
    NSString* deviceId = [[[UserManager defaultManager] pbUser] deviceId];
    NSString* newDeviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (newDeviceId && [newDeviceId isEqualToString:deviceId] == NO){
        return NO;
    }

    // check model
    NSString* deviceModel = [[[UserManager defaultManager] pbUser] deviceModel];
    NSString* newDeviceModel = [[UIDevice currentDevice] model];
    if (newDeviceModel && [newDeviceModel isEqualToString:deviceModel] == NO){
        return NO;
    }
    
    // check OS
    NSString* deviceOs = [[[UserManager defaultManager] pbUser] deviceOs];
    NSString* newDeviceOs = [DeviceDetection deviceOS];
    if (newDeviceOs && [newDeviceOs isEqualToString:deviceOs] == NO){
        return NO;
    }

    return YES;
}

- (void)uploadUserDeviceInfo:(BOOL)forceUpload
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue == NULL)
        return;
    
    if ([[UserManager defaultManager] hasUser] == NO){
        return;
    }

    NSString* userId = [[UserManager defaultManager] userId];
    if (forceUpload == NO && [self isUploadDone]){
        PPDebug(@"<uploadUserDeviceInfo> user %@ device info has uploaded", userId);
        return;
    }
    
    [self clearUploadDone];
    
    NSString* deviceModel = [[UIDevice currentDevice] model];
    NSString* deviceOS = [DeviceDetection deviceOS];
    NSString* newDeviceId = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    NSString* deviceToken = [[[UserManager defaultManager] pbUser] deviceToken];    
    

    
    
    dispatch_async(queue, ^{
        
        NSDictionary* para = @{ PARA_DEVICEMODEL : (deviceModel == nil) ? @"" : deviceModel,
                                PARA_DEVICEID : (newDeviceId == nil) ? @"" : newDeviceId,
                                PARA_DEVICETYPE : STRING_DEVICE_TYPE_IOS,
                                PARA_DEVICETOKEN : (deviceToken == nil) ? @"" : deviceToken,
                                PARA_DEVICEOS : (deviceOS == nil) ? @"" : deviceOS };
        
        
        GameNetworkOutput* output = [PPGameNetworkRequest apiServerGetAndResponseJSON:METHOD_UPDATE_USER_DEVICE
                                                                           parameters:para
                                                                        isReturnArray:NO];
        
        
        if (output.resultCode == ERROR_SUCCESS){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setUploadDone];

                [[UserManager defaultManager] setDeviceModel:deviceModel];
                [[UserManager defaultManager] setDeviceOS:deviceOS];
                [[UserManager defaultManager] setDeviceId:newDeviceId];
                [[UserManager defaultManager] storeUserData];                
            });
        }
        
    });
}

@end
