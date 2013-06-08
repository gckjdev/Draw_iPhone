//
//  GameNetworkRequest.m
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "StringUtil.h"
#import "JSON.h"
#import "LocaleUtils.h"
#import "UIDevice+IdentifierAddition.h"
#import "Reachability.h"
#import "PPApplication.h"
#import "DeviceDetection.h"
#import "ConfigManager.h"
#import "UIUtils.h"
#import "PPMessage.h"
#import "UserManager.h"

#define DEVICE_INFO_SEPERATOR   @"_"

//#define DRAW_GAME_ID_FOR_LEVEL  @"Game" // add by Benson, Draw&Guess App ID is Game

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
        NSString* deviceOS = [DeviceDetection deviceOS];        

        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:REGISTER_TYPE_EMAIL];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
        
        
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
        NSString* deviceOS = [DeviceDetection deviceOS];        
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REGISTERUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:REGISTER_TYPE_EMAIL];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
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
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
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
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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
                             refreshToken:(NSString*)refreshToken
                               expireDate:(NSDate*)expireDate
                                 qqOpenId:(NSString*)qqOpenId
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
        NSString* deviceOS = [DeviceDetection deviceOS];       
        
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
        
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];

        str = [str stringByAddQueryParameter:PARA_REFRESH_TOKEN value:refreshToken];
        str = [str stringByAddQueryParameter:PARA_QQ_OPEN_ID value:qqOpenId];
        str = [str stringByAddQueryParameter:PARA_EXPIRE_DATE intValue:[expireDate timeIntervalSince1970]];
        
        
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
                             refreshToken:(NSString*)refreshToken
                               expireDate:(NSDate*)expireDate
                                 qqOpenId:(NSString*)qqOpenId
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
        NSString* deviceOS = [DeviceDetection deviceOS];        
        
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
        
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
        
        if (refreshToken)
            str = [str stringByAddQueryParameter:PARA_REFRESH_TOKEN value:refreshToken];
        if (qqOpenId)
            str = [str stringByAddQueryParameter:PARA_QQ_OPEN_ID value:qqOpenId];
        if (expireDate)
            str = [str stringByAddQueryParameter:PARA_EXPIRE_DATE intValue:[expireDate timeIntervalSince1970]];
        
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
                            gender:(NSString*)gender
                             email:(NSString *)email
                          password:(NSString*)newPassword
                            avatar:(NSData*)avatar
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
        
        if (gender != nil && [gender length] > 0){
            str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        }
        
        if (email != nil && [email length] > 0){
            str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
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
                           gameId:(NSString*)gameId
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
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
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

+ (CommonNetworkOutput*)newLoginUser:(NSString*)baseURL
                            appId:(NSString*)appId
                           gameId:(NSString*)gameId
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
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];        
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
    
}


+ (CommonNetworkOutput*)getAllTrafficeServers:(NSString*)baseURL
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TRAFFIC_SERVER_LIST];   
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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

+ (CommonNetworkOutput*)chargeCoin:(NSString*)baseURL
                            userId:(NSString*)userId
                            amount:(int)amount
                            source:(int)source
                     transactionId:(NSString*)transactionId
                transactionReceipt:(NSString*)transactionRecepit
{
    return [GameNetworkRequest chargeCoin:baseURL userId:userId amount:amount source:source transactionId:transactionId transactionReceipt:transactionRecepit byUser:userId alixOrder:nil];
}

+ (CommonNetworkOutput*)chargeCoin:(NSString*)baseURL
                            userId:(NSString*)userId
                            amount:(int)amount
                            source:(int)source
                     transactionId:(NSString*)transactionId
                transactionReceipt:(NSString*)transactionRecepit
                            byUser:(NSString*)byUserId
                         alixOrder:(NSString *)alixOrder
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
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_ADMIN_USER_ID value:byUserId];
        
        str = [str stringByAddQueryParameter:PARA_ALIPAY_ORDER value:alixOrder];
        
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

+ (CommonNetworkOutput*)chargeIngot:(NSString*)baseURL
                             userId:(NSString*)userId
                             amount:(int)amount
                             source:(int)source
                      transactionId:(NSString*)transactionId
                 transactionReceipt:(NSString*)transactionRecepit
                             byUser:(NSString*)byUserId
                          alixOrder:(NSString *)alixOrder
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CHARGE_INGOT];
        str = [str stringByAddQueryParameter:PARA_SOURCE intValue:source];
        str = [str stringByAddQueryParameter:PARA_AMOUNT intValue:amount];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TRANSACTION_ID value:transactionId];
        str = [str stringByAddQueryParameter:PARA_TRANSACTION_RECEIPT value:transactionRecepit];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_ADMIN_USER_ID value:byUserId];
        
        str = [str stringByAddQueryParameter:PARA_ALIPAY_ORDER value:alixOrder];

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


+ (CommonNetworkOutput*)deductCoin:(NSString*)baseURL
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
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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
                            targetUserId:(NSString*)targetUserId
                             awardAmount:(int)awardAmount
                                awardExp:(int)awardExp
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_ITEM_AMOUNT];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_AMOUNT intValue:amount];        
        str = [str stringByAddQueryParameter:PARA_ITEM_TYPE intValue:itemType];     
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
        if ([targetUserId length] > 0){
            str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId];
            str = [str stringByAddQueryParameter:PARA_EXP intValue:awardExp];
            str = [str stringByAddQueryParameter:PARA_ACCOUNT_BALANCE intValue:awardAmount];
        }
        
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
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SYNC_ACCOUNT];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];

        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
//    return [PPNetworkRequest sendRequest:baseURL
//                     constructURLHandler:constructURLHandler
//                         responseHandler:responseHandler
//                                  output:output];
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
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
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SYNC_ACCOUNT];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_VERSION value:[UIUtils getAppVersion]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
//    return [PPNetworkRequest sendRequest:baseURL
//                     constructURLHandler:constructURLHandler
//                         responseHandler:responseHandler
//                                  output:output];
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
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
        
        UIDevice* myDevice = [UIDevice currentDevice];
        
        NSString* currnetNetwork = @"NONE";
        NetworkStatus currentStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if (currentStatus == ReachableViaWiFi) {
            currnetNetwork = @"WIFI";
        }
        if (currentStatus == ReachableViaWWAN) {
            currnetNetwork = @"WWAN";
        }
        NSString* basicInfo = [NSString stringWithFormat:@"\n设备(%@):%@\n系统:%@-%@\n版本:%@\n联网类型:%@\n", myDevice.model, [DeviceDetection platform], myDevice.systemName, myDevice.systemVersion, [PPApplication getAppVersion], currnetNetwork ];
        
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FEEDBACK];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        
        if ([feedback length] > 0){
            NSString* completeFeedback = [feedback stringByAppendingString:basicInfo];
            str = [str stringByAddQueryParameter:PARA_FEEDBACK value:completeFeedback];
        }
        if ([contact length] > 0) {
            str = [str stringByAddQueryParameter:PARA_CONTACT value:contact];
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

+ (CommonNetworkOutput*)commitWords:(NSString *)baseURL 
                              appId:(NSString *)appId 
                             userId:(NSString *)userId 
                              words:(NSString *)words
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_COMMIT_WORDS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        
        if (words && [words length] > 0){
            str = [str stringByAddQueryParameter:PARA_NEW_WORDS value:words];
        }
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

+ (CommonNetworkOutput*)newLoginUser:(NSString*)baseURL
                            appId:(NSString*)appId
                           gameId:(NSString*)gameId
                         deviceId:(NSString*)deviceId
                      deviceToken:(NSString*)deviceToken
                        autoRegister:(BOOL)autoRegister
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DEVICELOGIN];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];

        // add by Benson, 2013-04-15
        NSString* deviceOS = [DeviceDetection deviceOS];
        str = [str stringByAddQueryParameter:PARA_AUTO_REG intValue:autoRegister];
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
        
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
    
}

+ (CommonNetworkOutput*)loginUser:(NSString*)baseURL
                            appId:(NSString*)appId 
                           gameId:(NSString*)gameId
                            deviceId:(NSString*)deviceId
                      deviceToken:(NSString*)deviceToken

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DEVICELOGIN];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
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

+ (CommonNetworkOutput*)followUser:(NSString*)baseURL 
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                 targetUserIdArray:(NSArray*)targetUserIdArray
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* targetUserIdstr = @""; 
        for (NSString* targetUserId in targetUserIdArray) {
            targetUserIdstr = [targetUserIdstr stringByAppendingFormat:@"%@%@", STRING_SEPERATOR, targetUserId];
        }
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FOLLOWUSER]; 
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserIdstr]; 
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

+ (CommonNetworkOutput*)unFollowUser:(NSString*)baseURL
                               appId:(NSString*)appId
                              userId:(NSString*)userId
                   targetUserIdArray:(NSArray*)targetUserIdArray
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* targetUserIdstr = @"";
        for (NSString* targetUserId in targetUserIdArray) {
            targetUserIdstr = [targetUserIdstr stringByAppendingFormat:@"%@%@", STRING_SEPERATOR, targetUserId];
        }
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UNFOLLOWUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserIdstr];
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

+ (CommonNetworkOutput*)findFriends:(NSString*)baseURL
                              appId:(NSString*)appId 
                             gameId:(NSString*)gameId
                             userId:(NSString*)userId
                               type:(int)type 
                         startIndex:(NSInteger)startIndex 
                           endIndex:(NSInteger)endIndex
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FINDFRIENDS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_FRIENDSTYPE intValue:type];  
        str = [str stringByAddQueryParameter:PARA_START_INDEX intValue:startIndex];
        str = [str stringByAddQueryParameter:PARA_END_INDEX intValue:endIndex];
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


+ (CommonNetworkOutput*)getFriendList:(NSString*)baseURL
                                appId:(NSString*)appId 
                               gameId:(NSString*)gameId
                               userId:(NSString*)userId
                                 type:(NSInteger)type 
                               offset:(NSInteger)offset 
                                limit:(NSInteger)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_FRIEND_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_FRIENDSTYPE intValue:type];  
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
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


+ (CommonNetworkOutput*)getRelationCount:(NSString*)baseURL
                                   appId:(NSString*)appId
                                  gameId:(NSString*)gameId
                                  userId:(NSString*)userId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_RELATION_COUNT];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
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

+ (CommonNetworkOutput*)searchUsers:(NSString*)baseURL
                              appId:(NSString*)appId 
                             gameId:(NSString*)gameId
                             userId:(NSString*)userId
                          keyString:(NSString*)keyString 
                         startIndex:(NSInteger)startIndex 
                           endIndex:(NSInteger)endIndex
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SEARCHUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_SEARCHSTRING value:keyString]; 
        str = [str stringByAddQueryParameter:PARA_START_INDEX intValue:startIndex];
        str = [str stringByAddQueryParameter:PARA_END_INDEX intValue:endIndex];
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


#pragma mark - Friend Room

+ (CommonNetworkOutput*)createRoom:(NSString*)baseURL 
                          roomName:(NSString *)roomName  
                          password:(NSString *)password 
                            userId:(NSString *)userId 
                              nick:(NSString *)nick 
                            avatar:(NSString *)avatar 
                            gender:(NSString *)gender
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CREATE_ROOM];
        str = [str stringByAddQueryParameter:PARA_ROOM_NAME value:roomName];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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


+ (CommonNetworkOutput*)findRoomByUser:(NSString*)baseURL 
                            userId:(NSString *)userId 
                              offset:(NSInteger)offset
                            limit:(NSInteger)limit 
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FIND_ROOM_BY_USER];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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

+ (CommonNetworkOutput*)searhRoomWithKey:(NSString*)baseURL 
                                keyword:(NSString *)keyword 
                                offset:(NSInteger)offset
                                 limit:(NSInteger)limit 
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SEARCH_ROOM];
        str = [str stringByAddQueryParameter:PARA_KEYWORD value:keyword];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
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

+ (CommonNetworkOutput*)inviteUsersToRoom:(NSString*)baseURL 
                                   roomId:(NSString *)roomId                   
                                 password:(NSString *)password                   
                                   userId:(NSString *)userId                              
                                 userList:(NSString *)userList                                
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_INVITE_USER];
        str = [str stringByAddQueryParameter:PARA_ROOM_ID value:roomId];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_USERID_LIST value:userList];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];        

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

+ (CommonNetworkOutput*)removeRoom:(NSString*)baseURL 
                            roomId:(NSString *)roomId                   
                          password:(NSString *)password                   
                            userId:(NSString *)userId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REOMOVE_ROOM];
        str = [str stringByAddQueryParameter:PARA_ROOM_ID value:roomId];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];        
        
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


+ (CommonNetworkOutput*)uninvitedJoinRoom:(NSString*)baseURL 
                          roomId:(NSString *)roomId  
                          password:(NSString *)password 
                            userId:(NSString *)userId 
                              nick:(NSString *)nick 
                            avatar:(NSString *)avatar 
                            gender:(NSString *)gender
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_NEW_JOIN_ROOM];
        str = [str stringByAddQueryParameter:PARA_ROOM_ID value:roomId];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:password];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];        
        
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

+ (CommonNetworkOutput*)findDrawWithProtocolBuffer:(NSString*)baseURL
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_FINDDRAW];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];        
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
}


+ (CommonNetworkOutput*)matchDrawWithProtocolBuffer:(NSString*)baseURL 
                                             userId:(NSString *)userId 
                                             gender:(NSString *)gender 
                                               lang:(int)lang
                                               type:(NSInteger)type
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_MATCH_OPUS];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:lang];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];

        str = [str stringByAddQueryParameter:PARA_RETURN_DATA_METHOD intValue:1];           // if return URL, it's 1 else 0
        str = [str stringByAddQueryParameter:PARA_RETURN_COMPRESSED_DATA intValue:0];       // change to 0
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
}

+ (CommonNetworkOutput*)getFeedWithProtocolBuffer:(NSString*)baseURL 
                                             userId:(NSString *)userId 
                                             feedId:(NSString *)feedId
{
    BOOL isReturnDataURL = YES;
    
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        
        NSString* str = [NSString stringWithString:baseURL];       
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_OPUS_BY_ID];
        str = [str stringByAddQueryParameter:PARA_FEED_ID value:feedId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];        
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        
        if (isReturnDataURL){
            str = [str stringByAddQueryParameter:PARA_RETURN_DATA_METHOD intValue:1];
        }
        
        str = [str stringByAddQueryParameter:PARA_RETURN_COMPRESSED_DATA intValue:0];       // TODO, change to 0
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
}



+ (CommonNetworkOutput*)syncExpAndLevel:(NSString*)baseURL 
                                  appId:(NSString*)appId 
                                 gameId:(NSString*)gameId
                                 userId:(NSString*)userId 
                                  level:(int)level 
                                    exp:(long)exp 
                                   type:(int)type
                               awardExp:(long)awardExp
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];         
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SYND_LEVEL_EXP];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_LEVEL intValue:level];
        str = [str stringByAddQueryParameter:PARA_EXP intValue:exp];
        str = [str stringByAddQueryParameter:PARA_SYNC_TYPE intValue:type];       
        str = [str stringByAddQueryParameter:PARA_AWARD_EXP intValue:awardExp];       
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

+ (CommonNetworkOutput*)increaseExp:(NSString*)baseURL
                              appId:(NSString*)appId
                                 gameId:(NSString*)gameId
                                 userId:(NSString*)userId
                                    exp:(long)addExp
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_INCREASE_EXPERIENCE];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_EXP intValue:addExp];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        return str;
    };    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
    
    
}


+ (CommonNetworkOutput*)createOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                              nick:(NSString*)nick
                            avatar:(NSString*)avatar
                         signature:(NSString*)signature
                            gender:(NSString*)gender
                            wordId:(NSString*)wordId
                              word:(NSString *)word
                          wordType:(PBWordType)wordType
                             level:(NSInteger)level
                             score:(int)score
                              lang:(NSInteger)lang
                              data:(NSData*)data
                         imageData:(NSData *)imageData
                         targetUid:(NSString *)targetUid
                         contestId:(NSString *)contestId
                              desc:(NSString *)desc
                      isCompressed:(BOOL)isCompressed
                  progressDelegate:(id)progressDelegate;
{
//    BOOL isZipData = YES;   // for Benson test
    
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    NSString *method = METHOD_CREATE_OPUS_IMAGE;
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
                
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];                
        str = [str stringByAddQueryParameter:PARA_SIGNATURE value:signature];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_WORD_ID value:wordId];
        str = [str stringByAddQueryParameter:PARA_WORD value:word];
        str = [str stringByAddQueryParameter:PARA_LEVEL intValue:level];
        str = [str stringByAddQueryParameter:PARA_WORD_TYPE intValue:wordType];
        str = [str stringByAddQueryParameter:PARA_WORD_SCORE intValue:score];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:lang];
        str = [str stringByAddQueryParameter:PARA_DESC value:desc];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_IS_DATA_COMPRESSED boolValue:isCompressed];
        
        if ([targetUid length] != 0) {
            str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUid];            
        }
        if ([contestId length] != 0) {
            str = [str stringByAddQueryParameter:PARA_CONTESTID value:contestId];                        
        }
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
        // add device model
        NSString* deviceModel = [DeviceDetection platform];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:deviceModel];
        
//        if (isZipData){
//            str = [str stringByAddQueryParameter:PARA_IS_DATA_ZIP intValue:1];
//        }
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 

    
    if ([method isEqualToString:METHOD_CREATE_OPUS]) {
        return [PPNetworkRequest sendPostRequest:baseURL
                                            data:data
                             constructURLHandler:constructURLHandler
                                 responseHandler:responseHandler
                                    outputFormat:FORMAT_JSON
                                          output:output];        
    }else{
        NSMutableDictionary *dataDict = nil;
        if (data) {
            dataDict = [NSMutableDictionary dictionary];
            [dataDict setObject:data forKey:PARA_DRAW_DATA];
        }

        NSMutableDictionary *imageDict = nil;
        if (imageData) {
            imageDict = [NSMutableDictionary dictionary];
            [imageDict setObject:imageData forKey:PARA_DRAW_IMAGE];
        }

        return [PPNetworkRequest uploadRequest:baseURL
                                 imageDataDict:imageDict
                                  postDataDict:dataDict
                           constructURLHandler:constructURLHandler 
                               responseHandler:responseHandler 
                                        output:output
                              progressDelegate:progressDelegate];
        
    }
}

+ (CommonNetworkOutput*)rejectOpusDrawToMe:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId
                                    opusId:(NSString*)opusId
                                      type:(int)newType
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    if (userId == nil || opusId == nil){
        PPDebug(@"<rejectOpusDrawToMe> but userId nil or opusId nil");
        return nil;
    }
    
    NSString *method = METHOD_UPDATE_OPUS;
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:@""];
        str = [str stringByAddQueryParameter:PARA_TARGETUSER_NICKNAME value:@""];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:newType];
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:nil
                              postDataDict:nil
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];
    
}

+ (CommonNetworkOutput*)updateOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                            opusId:(NSString*)opusId
                              data:(NSData*)data
                         imageData:(NSData *)imageData
                      isCompressed:(BOOL)isCompressed
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    if (userId == nil || (data == nil && imageData == nil)){
        PPDebug(@"<updateOpus> but userId nil or data/imageData nil");
        return nil;
    }
    
    NSString *method = METHOD_UPDATE_OPUS;
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        
        // add device model
        NSString* deviceModel = [DeviceDetection platform];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:deviceModel];
        
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_IS_DATA_COMPRESSED boolValue:isCompressed];        
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    NSMutableDictionary *dataDict = nil;
    if (data) {
        dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:data forKey:PARA_DRAW_DATA];
    }
    NSMutableDictionary *imageDict = nil;
    if (imageData) {
        imageDict = [NSMutableDictionary dictionary];
        [imageDict setObject:imageData forKey:PARA_DRAW_IMAGE];
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];

}

+ (CommonNetworkOutput*)guessOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                              nick:(NSString*)nick
                            avatar:(NSString*)avatar
                            gender:(NSString*)gender
                            opusId:(NSString*)opusId                        
                    opusCreatorUId:(NSString*)opusCreatorUId  
                           isCorrect:(BOOL)isCorrect
                             score:(NSInteger)score
                           words:(NSString*)words
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_ACTION_ON_OPUS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];                
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
            
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_OPUS_CREATOR_UID value:opusCreatorUId];

        // add by XiaoTao, used to differentiate with old interface
        str = [str stringByAddQueryParameter:PARA_WORD_SCORE intValue:score];
        
        if (isCorrect) {
            str = [str stringByAddQueryParameter:PARA_CORRECT boolValue:isCorrect];            
        }
        str = [str stringByAddQueryParameter:PARA_WORD_LIST value:words];
        
        //TODO use type at Action Class. due to no Action Class, hard code now!
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:ACTION_TYPE_GUESS];
        
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        
        //action type
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



+ (CommonNetworkOutput*)commentOpus:(NSString*)baseURL
                            appId:(NSString*)appId
                           userId:(NSString*)userId
                             nick:(NSString*)nick
                           avatar:(NSString*)avatar
                           gender:(NSString*)gender
                           opusId:(NSString*)opusId                        
                   opusCreatorUId:(NSString*)opusCreatorUId  
                            comment:(NSString*)comment 
                          commentType:(int)commentType //comment info
                           commentId:(NSString *)commentId 
                      commentSummary:(NSString *)commentSummary
                       commentUserId:(NSString *)commentUserId 
                     commentNickName:(NSString *)commentNickName

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_ACTION_ON_OPUS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];                
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_OPUS_CREATOR_UID value:opusCreatorUId];
        str = [str stringByAddQueryParameter:PARA_COMMENT_CONTENT value:comment];

        //Comment info         
        str = [str stringByAddQueryParameter:PARA_COMMENT_TYPE intValue:commentType];
        str = [str stringByAddQueryParameter:PARA_COMMENT_ID value:commentId];
        str = [str stringByAddQueryParameter:PARA_COMMENT_SUMMARY value:commentSummary];
        str = [str stringByAddQueryParameter:PARA_COMMENT_USERID value:commentUserId];
        str = [str stringByAddQueryParameter:PARA_COMMENT_NICKNAME value:commentNickName];
        
        //TODO use type at Action Class. due to no Action Class, hard code now!
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:ACTION_TYPE_COMMENT];
        
        
        
        //action type
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

+ (CommonNetworkOutput*)getOpusCount:(NSString*)baseURL
                               appId:(NSString*)appId
                              userId:(NSString*)userId
                           targetUid:(NSString*)targetUid
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_OPUST_COUNT];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUid];
        //action type
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



+ (CommonNetworkOutput*)throwItemToOpus:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                                   nick:(NSString*)nick
                                 avatar:(NSString*)avatar
                                 gender:(NSString*)gender
                                 opusId:(NSString*)opusId                        
                         opusCreatorUId:(NSString*)opusCreatorUId
                               itemType:(int)itemType
                           awardBalance:(int)awardBalance
                               awardExp:(int)awardExp
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_ACTION_ON_OPUS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nick];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];                
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_OPUS_CREATOR_UID value:opusCreatorUId];
        
        //use item type as a action type. the action will show in the comment.
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:itemType];
        
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:opusCreatorUId];
        str = [str stringByAddQueryParameter:PARA_ACCOUNT_BALANCE intValue:awardBalance];
        str = [str stringByAddQueryParameter:PARA_EXP intValue:awardExp];

        //action type
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

+ (CommonNetworkOutput*)actionSaveOnOpus:(NSString*)baseURL                                  
                                   appId:(NSString*)appId                                 
                                  userId:(NSString*)userId
                              actionType:(int)actionType
                              actionName:(NSString*)actionName
                                  opusId:(NSString*)opusId                        
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_ACTION_ON_OPUS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                        
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_OPUS_CREATOR_UID value:opusId];        
        str = [str stringByAddQueryParameter:PARA_ACTION_NAME value:actionName];
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:actionType];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:[[UserManager defaultManager] getLanguageType]];        
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

+ (CommonNetworkOutput*)getMessageList:(NSString*)baseURL
                                 appId:(NSString*)appId
                                userId:(NSString*)userId
                          friendUserId:(NSString*)friendUserId
                            offsetMessageId:(NSString *)messageId
                              maxCount:(int)maxCount
                               forward:(BOOL)forward
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GETMESSAGELIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_TO_USERID value:friendUserId];
        
        str = [str stringByAddQueryParameter:PARA_MESSAGE_ID value:messageId];    
        str = [str stringByAddQueryParameter:PARA_FORWARD intValue:forward];
        
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:maxCount];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];

        str = [str stringByAddQueryParameter:PARA_VERSION intValue:1];
        
        
        // TOOD add other parameters
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}


+ (CommonNetworkOutput*)getMessageStatList:(NSString*)baseURL
                                 appId:(NSString*)appId
                                userId:(NSString*)userId
                                offset:(NSInteger)offset
                              maxCount:(int)maxCount
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GETMESSAGESTATLIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];            
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:maxCount];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_VERSION intValue:1];
        
        // TOOD add other parameters
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}

+ (CommonNetworkOutput*)sendMessage:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                       targetUserId:(NSString*)targetUserId
                               text:(NSString*)text
                               data:(NSData*)data
                               type:(int)type
                        hasLocation:(BOOL)hasLocation
                          longitude:(double)longitude
                           latitude:(double)latitude
                       reqMessageId:(NSString*)reqMessageId
                        replyResult:(int)replyResult

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SENDMESSAGE];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_TO_USERID value:targetUserId];
        str = [str stringByAddQueryParameter:PARA_MESSAGETEXT value:text];                

        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        if (hasLocation){
            str = [str stringByAddQueryParameter:PARA_LONGTITUDE doubleValue:longitude];
            str = [str stringByAddQueryParameter:PARA_LATITUDE doubleValue:latitude];
        }
        
        if (reqMessageId != nil){
            str = [str stringByAddQueryParameter:PARA_REQUEST_MESSAGE_ID value:reqMessageId];
            str = [str stringByAddQueryParameter:PARA_REPLY_RESULT intValue:replyResult];
        }
        
        // TOOD add other parameters
        str = [str stringByAddQueryParameter:PARA_VERSION intValue:1];        
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                        
        return;
    }; 
    
    if (type == MessageTypeImage){

        NSMutableDictionary *imageDict = nil;
        if (data) {
            imageDict = [NSMutableDictionary dictionary];
            [imageDict setObject:data forKey:PARA_IMAGE];
        }
        
        return [PPNetworkRequest uploadRequest:baseURL
                                 imageDataDict:imageDict
                                  postDataDict:nil
                           constructURLHandler:constructURLHandler
                               responseHandler:responseHandler
                                  outputFormat:FORMAT_JSON
                                        output:output];        
    }
    else{
        return [PPNetworkRequest sendPostRequest:baseURL
                                            data:data
                             constructURLHandler:constructURLHandler
                                 responseHandler:responseHandler
                                    outputFormat:FORMAT_JSON
                                          output:output];
    }
    
}

+ (CommonNetworkOutput*)userHasReadMessage:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId 
                              friendUserId:(NSString *)friendUserId
                                   
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_USER_READ_MSG];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:friendUserId];
        
        // TOOD add other parameters
        
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

+ (CommonNetworkOutput*)getFeedListWithProtocolBuffer:(NSString*)baseURL 
                                               userId:(NSString *)userId 
                                         feedListType:(NSInteger)feedListType
                                               offset:(NSInteger)offset
                                                limit:(NSInteger)limit 
                                                 lang:(NSInteger)lang;
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_FEED_LIST];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:feedListType];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:lang];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];                
        str = [str stringByAddQueryParameter:PARA_IMAGE intValue:1];                
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}



+ (CommonNetworkOutput*)getContestOpusListWithProtocolBuffer:(NSString*)baseURL
                                                   contestId:(NSString *)contestId
                                                      userId:(NSString *)userId 
                                                        type:(NSInteger)type
                                                      offset:(NSInteger)offset
                                                       limit:(NSInteger)limit 
                                                        lang:(NSInteger)lang
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_CONTEST_OPUS_LIST];
        str = [str stringByAddQueryParameter:PARA_CONTESTID value:contestId];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:lang];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];                
             
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}


+ (CommonNetworkOutput*)getFeedCommentListWithProtocolBuffer:(NSString*)baseURL 
                                                      opusId:(NSString *)opusId
                                                        type:(int)type
                                                      offset:(NSInteger)offset
                                                       limit:(NSInteger)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_FEED_COMMENT_LIST];
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:opusId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        str = [str stringByAddQueryParameter:PARA_APPID value:[ConfigManager appId]];
        str = [str stringByAddQueryParameter:PARA_RETURN_ITEM intValue:1];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}

+ (CommonNetworkOutput*)getMyCommentListWithProtocolBuffer:(NSString*)baseURL 
                                                    userId:(NSString *)userId
                                                     appId:(NSString *)appId
                                                    offset:(NSInteger)offset
                                                    limit:(NSInteger)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];       
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_MYCOMMENT_LIST];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL 
                     constructURLHandler:constructURLHandler 
                         responseHandler:responseHandler 
                            outputFormat:FORMAT_PB 
                                  output:output];
    
}

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                          deviceId:(NSString*)deviceId
                       deviceToken:(NSString*)deviceToken
                          nickName:(NSString*)nickName
                            gender:(NSString*)gender
                          password:(NSString*)newPassword
                            avatar:(NSString*)avatar 
                          location:(NSString*)location 
                            sinaId:(NSString*)sinaId 
                      sinaNickName:(NSString*)sinaNickName
                         sinaToken:(NSString*)sinaToken 
                        sinaSecret:(NSString*)sinaSecret
                  sinaRefreshToken:(NSString*)sinaRefreshToken
                    sinaExpireDate:(NSDate*)sinaExpireDate
                              qqId:(NSString*)qqId 
                        qqNickName:(NSString*)qqNickName
                           qqToken:(NSString*)qqToken 
                     qqTokenSecret:(NSString*)qqTokenSecret
                    qqRefreshToken:(NSString*)qqRefreshToken
                      qqExpireDate:(NSDate*)qqExpireDate
                          qqOpenId:(NSString*)qqOpenId
                        facebookId:(NSString*)facebookId
               facebookAccessToken:(NSString*)facebookAccessToken
                facebookExpireDate:(NSDate*)facebookExpireDate
                             email:(NSString *)email
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        NSString* deviceOS = [DeviceDetection deviceOS];        
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATEUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_EMAIL value:email];
        str = [str stringByAddQueryParameter:PARA_PASSWORD value:newPassword];
        str = [str stringByAddQueryParameter:PARA_REGISTER_TYPE intValue:REGISTER_TYPE_EMAIL];
        str = [str stringByAddQueryParameter:PARA_DEVICETOKEN value:deviceToken];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:deviceId];
        
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_LOCATION value:location];
        str = [str stringByAddQueryParameter:PARA_SOURCE value:appId];
        
        str = [str stringByAddQueryParameter:PARA_SINA_ID value:sinaId];
        str = [str stringByAddQueryParameter:PARA_SINA_ACCESS_TOKEN value:sinaToken];
        str = [str stringByAddQueryParameter:PARA_SINA_ACCESS_TOKEN_SECRET value:sinaSecret];
        str = [str stringByAddQueryParameter:PARA_SINA_NICKNAME value:sinaNickName];
        str = [str stringByAddQueryParameter:PARA_SINA_REFRESH_TOKEN value:sinaRefreshToken];
        if (sinaExpireDate){
            str = [str stringByAddQueryParameter:PARA_SINA_EXPIRE_DATE intValue:[sinaExpireDate timeIntervalSince1970]];
        }
               
        str = [str stringByAddQueryParameter:PARA_QQ_ID value:qqId];
        str = [str stringByAddQueryParameter:PARA_QQ_ACCESS_TOKEN value:qqToken];
        str = [str stringByAddQueryParameter:PARA_QQ_ACCESS_TOKEN_SECRET value:qqTokenSecret];
        str = [str stringByAddQueryParameter:PARA_QQ_NICKNAME value:qqNickName];
        str = [str stringByAddQueryParameter:PARA_QQ_OPEN_ID value:qqOpenId];
        str = [str stringByAddQueryParameter:PARA_QQ_REFRESH_TOKEN value:qqRefreshToken];
        if (qqExpireDate){
            str = [str stringByAddQueryParameter:PARA_QQ_EXPIRE_DATE intValue:[qqExpireDate timeIntervalSince1970]];
        }
        
        str = [str stringByAddQueryParameter:PARA_FACEBOOKID value:facebookId];
        str = [str stringByAddQueryParameter:PARA_FACEBOOK_ACCESS_TOKEN value:facebookAccessToken];
        if (facebookExpireDate){
            str = [str stringByAddQueryParameter:PARA_FACEBOOK_EXPIRE_DATE intValue:[facebookExpireDate timeIntervalSince1970]];
        }
        
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
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
                            userId:(NSString*)userId
                             appId:(NSString*)appId
                          newAppId:(NSString*)newAppId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL]; 
        NSString* deviceOS = [DeviceDetection deviceOS];        
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATEUSER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        if ([newAppId length] > 0){
            str = [str stringByAddQueryParameter:PARA_NEW_APPID value:newAppId];
        }
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:[[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]];                
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];                
        str = [str stringByAddQueryParameter:PARA_COUNTRYCODE value:[LocaleUtils getCountryCode]];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE value:[LocaleUtils getLanguageCode]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[UIDevice currentDevice].model];
        str = [str stringByAddQueryParameter:PARA_DEVICEOS value:deviceOS];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:DEVICE_TYPE_IOS];
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


+ (CommonNetworkOutput*)getOpusTimes:(NSString*)baseURL 
                                appId:(NSString *)appId 
                               feedId:(NSString *)feedId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_OUPS_TIMES];        
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];   
        str = [str stringByAddQueryParameter:PARA_OPUS_ID value:feedId];   
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

+ (CommonNetworkOutput*)getStatistics:(NSString*)baseURL 
                                appId:(NSString *)appId 
                               userId:(NSString *)userId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_STATISTICS];        
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];   
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

+ (CommonNetworkOutput*)reportStatus:(NSString*)baseURL 
                               appId:(NSString *)appId                                
                              userId:(NSString *)userId
                              status:(int)status
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_REPORT_STATUS];        
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];   
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];   
        str = [str stringByAddQueryParameter:PARA_STATUS intValue:status];           
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

+ (CommonNetworkOutput*)deleteMessage:(NSString*)baseURL 
                                appId:(NSString*)appId
                               userId:(NSString*)userId
                 targetMessageIdArray:(NSArray*)targetMessageIdArray
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* targetMessageIdstr = @""; 
        for (NSString* targetMessageId in targetMessageIdArray) {
            targetMessageIdstr = [targetMessageIdstr stringByAppendingFormat:@"%@%@", STRING_SEPERATOR, targetMessageId];
        }
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETEMESSAGE]; 
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGET_MESSAGE_ID value:targetMessageIdstr]; 
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

+ (CommonNetworkOutput*)deleteMessageStat:(NSString*)baseURL 
                                    appId:(NSString*)appId
                                   userId:(NSString*)userId
                             targetUserId:(NSString*)targetUserId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETEMESSAGE]; 
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId]; 
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

+ (CommonNetworkOutput*)getUserListSimpleInfo:(NSString*)baseURL
                                       userId:(NSString *)userId
                                        appId:(NSString*)appId
                                       gameId:(NSString*)gameId
                                    ByUserIds:(NSString*)targetUserIds
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TARGET_USER_LIST_INFO];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserIds];
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

+ (CommonNetworkOutput*)getUserSimpleInfo:(NSString*)baseURL
                                   userId:(NSString *)userId
                                    appId:(NSString*)appId
                                   gameId:(NSString*)gameId
                                 ByUserId:(NSString*)targetUserId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TARGET_USER_INFO];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId];
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


+ (CommonNetworkOutput*)getUserInfo:(NSString*)baseURL
                                   userId:(NSString *)userId
                                    appId:(NSString*)appId 
                                   gameId:(NSString*)gameId
                                 ByUserId:(NSString*)targetUserId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TARGET_USER_INFO];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];                
        return;
    }; 
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

+ (CommonNetworkOutput*)getTopPalyerList:(NSString*)baseURL 
                                    appId:(NSString*)appId 
                                  gameId:(NSString*)gameId 
                                  userId:(NSString *)userId
                                    type:(int)type
                                   offset:(NSInteger)offset
                                    limit:(NSInteger)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_TOP_PLAYERS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
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


+ (CommonNetworkOutput*)deleteFeed:(NSString*)baseURL 
                             appId:(NSString*)appId
                            feedId:(NSString*)feedId 
                            userId:(NSString *)userId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETE_FEED];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_FEED_ID value:feedId];
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

+ (CommonNetworkOutput*)getRecommendApp:(NSString*)baseURL
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];               
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


+ (CommonNetworkOutput*)getContests:(NSString*)baseURL
                              appId:(NSString*)appId
                              userId:(NSString*)userId
                               type:(NSInteger)type
                             offset:(NSInteger)offset
                             limit:(NSInteger)limit
                           language:(NSInteger)language
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];  
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_CONTEST_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:language];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        
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

+ (CommonNetworkOutput*)createWall:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                              data:(NSData *)data
                         imageData:(NSData *)imageData
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
        
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CREATE_USER_WALL];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
//    return [PPNetworkRequest sendPostRequest:baseURL
//                                        data:data
//                         constructURLHandler:constructURLHandler
//                             responseHandler:responseHandler
//                                outputFormat:FORMAT_PB
//                                      output:output];
    
    NSMutableDictionary *dataDict = nil;
    if (data) {
        dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:data forKey:PARA_WALL_DATA];
    }
    
    NSMutableDictionary *imageDict = nil;
    if (imageData) {
        imageDict = [NSMutableDictionary dictionary];
        [imageDict setObject:imageData forKey:PARA_WALL_BG_IMAGE];
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                              outputFormat:FORMAT_PB
                                    output:output];
}

+ (CommonNetworkOutput*)updateWall:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                            wallId:(NSString *)wallId
                              data:(NSData *)data
                         imageData:(NSData *)imageData
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_USER_WALL];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_WALL_ID value:wallId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    //    return [PPNetworkRequest sendPostRequest:baseURL
    //                                        data:data
    //                         constructURLHandler:constructURLHandler
    //                             responseHandler:responseHandler
    //                                outputFormat:FORMAT_PB
    //                                      output:output];
    
    NSMutableDictionary *dataDict = nil;
    if (data) {
        dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:data forKey:PARA_WALL_DATA];
    }
    
    NSMutableDictionary *imageDict = nil;
    if (imageData) {
        imageDict = [NSMutableDictionary dictionary];
        [imageDict setObject:imageData forKey:PARA_WALL_BG_IMAGE];
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                              outputFormat:FORMAT_PB
                                    output:output];
}



+ (CommonNetworkOutput*)getWall:(NSString *)baseURL
                          appId:(NSString *)appId
                         userId:(NSString *)userId
                         wallId:(NSString *)wallId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_USER_WALL];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_WALL_ID value:wallId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

+ (CommonNetworkOutput*)getWalls:(NSString *)baseURL
                           appId:(NSString *)appId
                          userId:(NSString *)userId
                        wallType:(PBWallType)wallType
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_USER_WALL_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_WALL_TYPE intValue:wallType];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

+ (CommonNetworkOutput*)blackUser:(NSString*)baseURL
                            appId:(NSString* )appId
                     targetUserId:(NSString*)targetUserId
                           userId:(NSString*)userId
                   targetDeviceId:(NSString*)targetDeviceId
                             type:(int)type
                       actionType:(int)actionType
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_BLACK_USER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId];
        str = [str stringByAddQueryParameter:PARA_DEVICEID value:targetDeviceId];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:type];
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:actionType];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                            appId:(NSString* )appId
                           userId:(NSString*)userId
                              data:(NSData*)data
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_NEW_UPDATE_USER];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendPostRequest:baseURL
                                        data:data
                         constructURLHandler:constructURLHandler
                             responseHandler:responseHandler
                                outputFormat:FORMAT_JSON
                                      output:output];
}

+ (CommonNetworkOutput*)blackFriend:(NSString*)baseURL
                              appId:(NSString* )appId
                       targetUserId:(NSString*)targetUserId
                             userId:(NSString*)userId
                         actionType:(int)actionType
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_BLACK_FRIEND];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUserId];
        str = [str stringByAddQueryParameter:PARA_TYPE intValue:actionType];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}



+ (CommonNetworkOutput *)buyItem:(NSString *)baseURL
                           appId:(NSString *)appId
                          userId:(NSString *)userId
                          itemId:(int)itemId
                           count:(int)count
                           price:(int)price
                        currency:(PBGameCurrency)currency
                          toUser:(NSString *)toUser
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_BUY_ITEM];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_ITEMID intValue:itemId];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:count];
        str = [str stringByAddQueryParameter:PARA_PRICE intValue:price];
        str = [str stringByAddQueryParameter:PARA_CURRENCY intValue:currency];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:toUser];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

// consume item
+ (CommonNetworkOutput *)consumeItem:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                              itemId:(int)itemId
                               count:(int)count
                            forceBuy:(BOOL)forceBuy // 若不够钱是否强制购买后消耗
                               price:(int)price
                            currency:(PBGameCurrency)currency
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CONSUME_ITEM];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_ITEMID intValue:itemId];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:count];
        str = [str stringByAddQueryParameter:PARA_PRICE intValue:price];
        str = [str stringByAddQueryParameter:PARA_CURRENCY intValue:currency];
        str = [str stringByAddQueryParameter:PARA_FORCE_BUY boolValue:forceBuy];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:[DeviceDetection deviceType]];
        str = [str stringByAddQueryParameter:PARA_DEVICEMODEL value:[DeviceDetection platform]];
        str = [str stringByAddQueryParameter:PARA_FORMAT value:FINDDRAW_FORMAT_PROTOCOLBUFFER];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

+ (CommonNetworkOutput*)uploadUserImage:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                              imageData:(NSData*)imageData
                              imageType:(NSString*)imageType
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPLOAD_USER_IMAGE];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:imageType intValue:1];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest uploadRequest:baseURL
                                uploadData:imageData
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];
    
}

+ (CommonNetworkOutput*)queryGeocodeWithLatitude:(double)latitude
                                       longitude:(double)longitude
                                        language:(NSString *)language
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL)  {
        NSString* str = [NSString stringWithString:baseURL];
        NSString *latLngStr = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
        str = [str stringByAddQueryParameter:PARA_GOOGLE_LATLNG value:latLngStr];
        str = [str stringByAddQueryParameter:PARA_GOOGLE_LANGUAGE value:language];
        str = [str stringByAddQueryParameter:PARA_GOOGLE_SENSOR value:@"true"];
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = dict;
        return;
    };
    
    return [PPNetworkRequest sendRequest:URL_GOOGLE_GEOCODE_JSON
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_JSON
                                  output:output];
}




//when returnPB is YES, the returnArray has no sence.
+ (CommonNetworkOutput*)sendGetRequestWithBaseURL:(NSString*)baseURL
                                           method:(NSString *)method
                                      parameters:(NSDictionary *)parameters
                                        returnPB:(BOOL)returnPB
                                     returnArray:(BOOL)returnArray
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL)  {
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:method];
        for (NSString *key in [parameters allKeys]) {
            NSString *value = [parameters objectForKey:key];
            str = [str stringByAddQueryParameter:key value:value];
        }
        if (returnPB) {
            str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        }
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        if (returnArray && !returnPB) {
            output.jsonDataArray = [dict objectForKey:RET_DATA];
        }else{
            output.jsonDataDict = [dict objectForKey:RET_DATA];
        }
        return;
    };
    
    int format = returnPB ? FORMAT_PB : FORMAT_JSON;
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:format
                                  output:output];
}

+ (CommonNetworkOutput*)submitOpus:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                      opusMetaData:(NSData *)opusMetaData
                         imageData:(NSData *)imageData
                          opusData:(NSData *)opusData
                  progressDelegate:(id)progressDelegate{
    
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];

    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_SUBMIT_OPUS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (opusMetaData) {
        [dataDict setObject:opusMetaData forKey:PARA_OPUS_META_DATA];
    }
    
    if (opusData) {
        [dataDict setObject:opusData forKey:PARA_OPUS_DATA];
    }
    
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionary];
    if (imageData) {
        [imageDict setObject:imageData forKey:PARA_OPUS_IMAGE_DATA];
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output
                          progressDelegate:progressDelegate];
}

+ (CommonNetworkOutput*)addUserPhoto:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                                data:(NSData*)data
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_ADD_USER_PHOTO];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];

        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendPostRequest:baseURL
                                        data:data
                         constructURLHandler:constructURLHandler
                             responseHandler:responseHandler
                                outputFormat:FORMAT_PB
                                      output:output];
}

+ (CommonNetworkOutput*)getUserPhoto:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                            tagArray:(NSString *)tagArrayString
                               usage:(int)usage
                              offset:(int)offset
                               limit:(int)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_USER_PHOTO_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_USER_PHOTO_TAGS value:tagArrayString];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_COUNT intValue:limit];
        str = [str stringByAddQueryParameter:PARA_USAGE intValue:usage];
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_PB
                                  output:output];
}

+ (CommonNetworkOutput*)updateUserPhoto:(NSString *)baseURL
                                  appId:(NSString *)appId
                                 userId:(NSString *)userId
                                   data:(NSData*)data
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_USER_PHOTO];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    
    return [PPNetworkRequest sendPostRequest:baseURL
                                        data:data
                         constructURLHandler:constructURLHandler
                             responseHandler:responseHandler
                                outputFormat:FORMAT_PB
                                      output:output];
}

+ (CommonNetworkOutput*)deleteUserPhoto:(NSString *)baseURL
                                  appId:(NSString *)appId
                                 userId:(NSString *)userId
                            userPhotoId:(NSString *)userPhotoId
                                  usage:(int)usage

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETE_USER_PHOTO];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_USER_PHOTO_ID value:userPhotoId];
        str = [str stringByAddQueryParameter:PARA_USAGE intValue:usage];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        return;
    };
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler responseHandler:responseHandler
                                  output:output];
}


@end
