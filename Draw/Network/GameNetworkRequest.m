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

#define DEVICE_INFO_SEPERATOR   @"_"
#define DEVICE_TYPE_IOS         1


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
        NSString* deviceOS = [NSString stringWithFormat:@"%@_%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
        
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
        NSString* deviceOS = [NSString stringWithFormat:@"%@_%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
        
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
        NSString* deviceOS = [NSString stringWithFormat:@"%@_%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
        
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
        NSString* deviceOS = [NSString stringWithFormat:@"%@_%@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
        
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
        
        if (gender != nil && [gender length] > 0){
            str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
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
            str = [str stringByAddQueryParameter:PARA_NEW_WORDS value:[words stringByURLEncode]];            
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

+ (CommonNetworkOutput*)searchUsers:(NSString*)baseURL
                              appId:(NSString*)appId
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

@end
