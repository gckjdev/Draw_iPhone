//
//  BulletinNetwork.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinNetwork.h"
#import "BulletinNetworkConstants.h"
#import "PPNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "StringUtil.h"
#import "ConfigManager.h"


@implementation BulletinNetwork

+ (CommonNetworkOutput*)getBulletins:(NSString*)baseURL
                               appId:(NSString*)appId
                              gameId:(NSString*)gameId
                              userId:(NSString*)userId
                          bulletinId:(NSString*)bulletinId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GETBULLETINS];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_LATEST_BULLETIN_ID value:bulletinId];
        
        
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
