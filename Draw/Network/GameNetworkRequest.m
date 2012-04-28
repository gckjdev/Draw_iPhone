//
//  GameNetworkRequest.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "StringUtil.h"
#import "JSON.h"
#import "LocaleUtils.h"
#import "UIDevice+IdentifierAddition.h"


@implementation GameNetworkRequest

+ (CommonNetworkOutput*)registerUserByEmail:(NSString*)baseURL
                                      appId:(NSString*)appId
                                      email:(NSString*)email
                                   password:(NSString*)password
                                deviceToken:(NSString*)deviceToken
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:REGISTER_TYPE_EMAIL];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
    
}
+ (CommonNetworkOutput*)registerUserByEmail:(NSString*)baseURL
                                      appId:(NSString*)appId
                                      email:(NSString*)email
                                   password:(NSString*)password
                                deviceToken:(NSString*)deviceToken 
                                   deviceId:(NSString*)deviceId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:REGISTER_TYPE_EMAIL];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
    
}


+ (CommonNetworkOutput*)fetchShoppingList:(NSString*)baseURL type:(int)type
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FETCH_SHOPPING_LIST];
        str = [str stringByAddQueryParameter:PARA_SHOPPING_TYPE intValue:type];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataArray = [dict objectForKey:RET_DATA];
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
    
}


+ (CommonNetworkOutput*)fetchAccountBalance:(NSString*)baseURL userId:(NSString *)userId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_ACCOUNT_BALANCE];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataArray = [dict objectForKey:RET_DATA];
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
} 

+ (CommonNetworkOutput*)registerUserBySNS:(NSString*)baseURL
                                    snsId:(NSString*)snsId
                             registerType:(int)registerType                                      
                                    appId:(NSString*)appId
                              deviceToken:(NSString*)deviceToken
                                 nickName:(NSString*)nickName
                                   avatar:(NSString*)avatar
                              accessToken:(NSString*)accessToken
                        accessTokenSecret:(NSString*)accessTokenSecret
                                 province:(int)province
                                     city:(int)city
                                 location:(NSString*)location
                                   gender:(NSString*)gender
                                 birthday:(NSString*)birthday
                                   domain:(NSString*)domain
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_SNS_ID value:snsId];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:registerType];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_ACCESS_TOKEN value:accessToken];
        str = [str stringByAddQueryParameter:PARA_ACCESS_TOKEN_SECRET value:accessTokenSecret];
        str = [str stringByAddQueryParameter:PARA_PROVINCE intValue:province];
        str = [str stringByAddQueryParameter:PARA_CITY intValue:city];
        str = [str stringByAddQueryParameter:PARA_LOCATION value:location];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_BIRTHDAY value:birthday];
        str = [str stringByAddQueryParameter:PARA_DOMAIN value:domain];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];    
}

+ (CommonNetworkOutput*)registerUserBySNS:(NSString*)baseURL
                                    snsId:(NSString*)snsId
                             registerType:(int)registerType                                      
                                    appId:(NSString*)appId
                              deviceToken:(NSString*)deviceToken
                                 nickName:(NSString*)nickName
                                   avatar:(NSString*)avatar
                              accessToken:(NSString*)accessToken
                        accessTokenSecret:(NSString*)accessTokenSecret
                                 province:(int)province
                                     city:(int)city
                                 location:(NSString*)location
                                   gender:(NSString*)gender
                                 birthday:(NSString*)birthday
                                   domain:(NSString*)domain 
                                 deviceId:(NSString*)deviceId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_SNS_ID value:snsId];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:registerType];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_ACCESS_TOKEN value:accessToken];
        str = [str stringByAddQueryParameter:PARA_ACCESS_TOKEN_SECRET value:accessTokenSecret];
        str = [str stringByAddQueryParameter:PARA_PROVINCE intValue:province];
        str = [str stringByAddQueryParameter:PARA_CITY intValue:city];
        str = [str stringByAddQueryParameter:PARA_LOCATION value:location];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_BIRTHDAY value:birthday];
        str = [str stringByAddQueryParameter:PARA_DOMAIN value:domain];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];    
}

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                          deviceId:(NSString*)deviceId
                       deviceToken:(NSString*)deviceToken
                          nickName:(NSString*)nickName
                          password:(NSString*)newPassword
                            avatar:(NSData*)avatar
//                       newPassword:(NSString*)newPassword
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATEUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        
        if ([deviceId length] > 0){
            str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];            
        }
        
        if ([deviceToken length] > 0){
            str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        }
        
        if ([nickName length] > 0){
            str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];            
        }
        
        if ([newPassword length] > 0){
            str = [str stringByAddQueryParameter:PARA_PASSWORD value:newPassword];            
        }
        
        if (avatar != nil && [avatar length] > 0){
            NSString* HAS_AVATAR = @"1";
            str = [str stringByAddQueryParameter:PARA_AVATAR value:HAS_AVATAR];
        }
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest uploadRequest:baseURL
                                uploadData:avatar
                       constructURLHandler:constructURLHandler                       
                           responseHandler:responseHandler                           
                                    output:output];
    
}

+ (CommonNetworkOutput*)loginUser:(NSString*)baseURL
                            appId:(NSString*)appId
                            email:(NSString*)email 
                         password:(NSString*)password 
                      deviceToken:(NSString*)deviceToken

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_LOGIN];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
}

+ (CommonNetworkOutput*)getAllTrafficeServers:(NSString*)baseURL
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TRAFFIC_SERVER_LIST];        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataArray = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}

+ (CommonNetworkOutput*)chargeAccount:(NSString*)baseURL
                               userId:(NSString*)userId
                               amount:(int)amount
                               source:(int)source
                        transactionId:(NSString*)transactionId
                   transactionReceipt:(NSString*)transactionRecepit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CHARGE_ACCOUNT];      
        str = [str stringByAddQueryParameter:PARA_SOURCE intValue:source];
        str = [str stringByAddQueryParameter:PARA_AMOUNT intValue:amount];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TRANSACTION_ID value:transactionId];
        str = [str stringByAddQueryParameter:PARA_TRANSACTION_RECEIPT value:transactionRecepit];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
}

+ (CommonNetworkOutput*)deductAccount:(NSString*)baseURL
                               userId:(NSString*)userId
                               amount:(int)amount
                               source:(int)source
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DEDUCT_ACCOUNT];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_SOURCE intValue:source];
        str = [str stringByAddQueryParameter:PARA_AMOUNT intValue:amount];        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
}

+ (CommonNetworkOutput*)updateBalance:(NSString*)baseURL
                               userId:(NSString*)userId
                              balance:(int)balance
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_ACCOUNT_BALANCE];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_ACCOUNT_BALANCE intValue:balance];        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
}

+ (CommonNetworkOutput*)updateItemAmount:(NSString*)baseURL
                                  userId:(NSString*)userId
                                itemType:(int)itemType
                                  amount:(int)amount
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_ITEM_AMOUNT];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_AMOUNT intValue:amount];        
        str = [str stringByAddQueryParameter:PARA_ITEM_TYPE intValue:itemType];        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
    
}

+ (CommonNetworkOutput*)syncUserAccontAndItem:(NSString*)baseURL 
                                       userId:(NSString*)userId 
                                     
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SYNC_USER_ACCOUNT_ITEM];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
    
}

+ (CommonNetworkOutput*)syncUserAccontAndItem:(NSString*)baseURL 
                                       userId:(NSString*)userId 
                                     deviceId:(NSString*)deviceId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SYNC_USER_ACCOUNT_ITEM];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}

+ (CommonNetworkOutput*)feedbackUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId 
                            feedback:(NSString*)feedback 
                             contact:(NSString*)contact
                              type:(int)type
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FEEDBACK];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        
        if ([feedback length] > 0){
            str = [str stringByAddQueryParameter:PARA_FEEDBACK value:[feedback stringByURLEncode]];            
        }
        if ([contact length] > 0) {
            str = [str stringByAddQueryParameter:PARA_CONTACT value:[contact stringByURLEncode]];  
        }
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}

+ (CommonNetworkOutput*)loginUser:(NSString*)baseURL
                            appId:(NSString*)appId
                            deviceId:(NSString*)deviceId
                      deviceToken:(NSString*)deviceToken

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DEVICELOGIN];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];        
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
    
}
@end
