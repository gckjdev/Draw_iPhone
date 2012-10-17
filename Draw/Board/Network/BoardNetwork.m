//
//  AnnounceNetwork.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BoardNetwork.h"
#import "BoardNetworkConstant.h"
#import "PPNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "StringUtil.h"
#import "ConfigManager.h"


@implementation BoardNetwork

+ (CommonNetworkOutput*)getBoards:(NSString*)baseURL
                                      appId:(NSString*)appId
                                      gameId:(NSString*)gameId
                                      deviceType:(int)deviceType //ipad iphone?
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];  
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GETBOARDLIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        
        
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

+ (CommonNetworkOutput*)updateBoardStatictic:(NSString*)baseURL
                                       appId:(NSString*)appId
                                      gameId:(NSString*)gameId 
                                     boardId:(NSString *)boardId
                                      userId:(NSString *)userId
                                  deviceType:(int)deviceType //ipad iphone?
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];  
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_UPDATE_BOARD_STATISTIC];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_BOARDID value:boardId];
        
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



@end
