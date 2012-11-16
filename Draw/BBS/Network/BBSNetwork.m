//
//  BBSNetwork.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSNetwork.h"
#import "PPNetworkRequest.h"
#import "StringUtil.h"


@implementation BBSNetwork


+ (CommonNetworkOutput*)getBBSBoardList:(NSString*)baseURL
                                 appId:(NSString*)appId
                                userId:(NSString*)userId
                            deviceType:(int)deviceType

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBSBOARD_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
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
