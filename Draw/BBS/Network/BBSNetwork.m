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

+ (CommonNetworkOutput*)createPost:(NSString*)baseURL
                             appId:(NSString*)appId
                        deviceType:(int)deviceType
                            userId:(NSString*)userId
                          nickName:(NSString*)nickName
                            gender:(NSString*)gender
                            avatar:(NSString*)avatar
                           boradId:(NSString*)boardId
                       contentType:(NSInteger)contentType
                              text:(NSString *)text
                             image:(NSData *)image
                          drawData:(NSData *)drawData
                         drawImage:(NSData *)drawImage
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    if (userId == nil || boardId == nil){
        PPDebug(@"<updateOpus> but userId nil or data/imageData nil");
        return nil;
    }
    
    NSString *method = METHOD_CREATE_POST;
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];

        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        str = [str stringByAddQueryParameter:PARA_BOARDID value:boardId];
        
        str = [str stringByAddQueryParameter:PARA_CONTENT_TYPE intValue:contentType];
        str = [str stringByAddQueryParameter:PARA_TEXT_CONTENT value:text];
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    NSMutableDictionary *dataDict = nil;
    if (drawData) {
        dataDict = [NSMutableDictionary dictionary];
        [dataDict setObject:drawData forKey:PARA_DRAW_DATA];
    }

    NSData *iData = nil;
    NSString *iKey = nil;
    if (contentType == 2) {
        iData = image;
        iKey = PARA_IMAGE;
    }else if(contentType == 4){
        iData = drawImage;
        iKey = PARA_DRAW_IMAGE;
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                                 imageData:iData
                                  imageKey:iKey
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];
}

@end
