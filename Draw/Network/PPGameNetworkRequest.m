//
//  PPGameNetworkRequest.m
//  Draw
//
//  Created by qqn_pipi on 13-6-9.
//
//

#import "PPGameNetworkRequest.h"
#import "PPNetworkConstants.h"
#import "StringUtil.h"
#import "UserManager.h"

@implementation PPGameNetworkRequest


+ (NSString*)addDefaultParameters:(NSString*)str parameters:(NSDictionary*)para
{
    // userId
    if (para == nil || [para objectForKey:PARA_USERID] == nil){
        NSString* userId = [[UserManager defaultManager] userId];
        if ([userId length] > 0){
            str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        }
    }
    
    // appId
    if (para == nil || [para objectForKey:PARA_APPID] == nil){
        str = [str stringByAddQueryParameter:PARA_APPID value:[GameApp appId]];
    }
    
    // gameId
    if (para == nil || [para objectForKey:PARA_GAME_ID] == nil){
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:[GameApp gameId]];
    }
    
    return str;
}

//when returnPB is YES, the returnArray has no sence.
+ (GameNetworkOutput*)sendGetRequestWithBaseURL:(NSString*)baseURL
                                         method:(NSString *)method
                                     parameters:(NSDictionary *)parameters
                                       returnPB:(BOOL)returnPB
                                returnJSONArray:(BOOL)returnJSONArray
{
    GameNetworkOutput* output = [[[GameNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL)  {
        
        PPDebug(@"<GET> parameters=%@, isReturnProtocolBuffer=%d, isReturnJSONArray=%d", [parameters description], returnPB, returnJSONArray);
        
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [self addDefaultParameters:str parameters:parameters];
        for (NSString *key in [parameters allKeys]) {
            NSString *value = [parameters objectForKey:key];
            str = [str stringByAddQueryParameter:key value:value];
        }
        if (returnPB) {
            str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        }
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *origOutput) {
        
        if (returnPB){
            @try {
                GameNetworkOutput* output = nil;
                if ([output isKindOfClass:[GameNetworkOutput class]]){
                    output = (GameNetworkOutput*)origOutput;
                }
                
                if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){
                    output.pbResponse = [DataQueryResponse parseFromData:output.responseData];
                    output.resultCode = output.pbResponse.resultCode;
                }
                
                PPDebug(@"RECV PB DATA, RESULT CODE = %d", output.resultCode);
            }
            @catch (NSException *exception) {
                PPDebug(@"RECV PB DATA but catch exception = %@", [exception debugDescription]);
                output.resultCode = ERROR_CLIENT_PARSE_DATA;
            }
        }
        else{
            // for JSON handling
            if (returnJSONArray) {
                output.jsonDataArray = [dict objectForKey:RET_DATA];
            }else{
                output.jsonDataDict = [dict objectForKey:RET_DATA];
            }
        }
        return;
    };
    
    int format = returnPB ? FORMAT_PB : FORMAT_JSON;
    
    return (GameNetworkOutput*)[PPNetworkRequest sendRequest:baseURL
                                         constructURLHandler:constructURLHandler
                                             responseHandler:responseHandler
                                                outputFormat:format
                                                      output:output];
}

//when returnPB is YES, the returnArray has no sence.
+ (GameNetworkOutput*)sendPostRequestWithBaseURL:(NSString*)baseURL
                                          method:(NSString *)method
                                      parameters:(NSDictionary *)parameters
                                        postData:(NSData*)postData
                                        returnPB:(BOOL)returnPB
                                 returnJSONArray:(BOOL)returnJSONArray
{
    GameNetworkOutput* output = [[[GameNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL)  {
        
        PPDebug(@"<POST> parameters=%@, isReturnProtocolBuffer=%d, isReturnJSONArray=%d", [parameters description], returnPB, returnJSONArray);
        
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [self addDefaultParameters:str parameters:parameters];        
        for (NSString *key in [parameters allKeys]) {
            NSString *value = [parameters objectForKey:key];
            str = [str stringByAddQueryParameter:key value:value];
        }
        if (returnPB) {
            str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        }
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *origOutput) {
        
        if (returnPB){
            @try {
                GameNetworkOutput* output = nil;
                if ([output isKindOfClass:[GameNetworkOutput class]]){
                    output = (GameNetworkOutput*)origOutput;
                }
                
                if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){
                    output.pbResponse = [DataQueryResponse parseFromData:output.responseData];
                    output.resultCode = output.pbResponse.resultCode;
                }
                
                PPDebug(@"RECV PB DATA, RESULT CODE = %d", output.resultCode);
            }
            @catch (NSException *exception) {
                PPDebug(@"RECV PB DATA but catch exception = %@", [exception debugDescription]);
                output.resultCode = ERROR_CLIENT_PARSE_DATA;
            }
        }
        else{
            // for JSON handling
            if (returnJSONArray) {
                output.jsonDataArray = [dict objectForKey:RET_DATA];
            }else{
                output.jsonDataDict = [dict objectForKey:RET_DATA];
            }
        }
        return;
    };
    
    int format = returnPB ? FORMAT_PB : FORMAT_JSON;
    
    return (GameNetworkOutput*)[PPNetworkRequest sendPostRequest:baseURL
                                                            data:postData
                                             constructURLHandler:constructURLHandler
                                                 responseHandler:responseHandler
                                                    outputFormat:format
                                                          output:output];
}

//when returnPB is YES, the returnArray has no sence.
+ (GameNetworkOutput*)uploadDataRequestWithBaseURL:(NSString*)baseURL
                                            method:(NSString *)method
                                        parameters:(NSDictionary *)parameters
                                     imageDataDict:(NSDictionary *)imageDict
                                      postDataDict:(NSDictionary *)dataDict
                                          returnPB:(BOOL)returnPB
                                   returnJSONArray:(BOOL)returnJSONArray
                                  progressDelegate:(id)progressDelegate

{
    GameNetworkOutput* output = [[[GameNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL)  {
        
        PPDebug(@"<UPLOAD> parameters=%@, isReturnProtocolBuffer=%d, isReturnJSONArray=%d", [parameters description], returnPB, returnJSONArray);
        
        NSString* str = [NSString stringWithString:baseURL];
        str = [str stringByAddQueryParameter:METHOD value:method];
        str = [self addDefaultParameters:str parameters:parameters];        
        for (NSString *key in [parameters allKeys]) {
            NSString *value = [parameters objectForKey:key];
            str = [str stringByAddQueryParameter:key value:value];
        }
        if (returnPB) {
            str = [str stringByAddQueryParameter:PARA_FORMAT value:FORMAT_PROTOCOLBUFFER];
        }
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *origOutput) {
        
        if (returnPB){
            @try {
                GameNetworkOutput* output = nil;
                if ([output isKindOfClass:[GameNetworkOutput class]]){
                    output = (GameNetworkOutput*)origOutput;
                }
                
                if (output.resultCode == ERROR_SUCCESS && output.responseData != nil){
                    output.pbResponse = [DataQueryResponse parseFromData:output.responseData];
                    output.resultCode = output.pbResponse.resultCode;
                }
                
                PPDebug(@"RECV PB DATA, RESULT CODE = %d", output.resultCode);
            }
            @catch (NSException *exception) {
                PPDebug(@"RECV PB DATA but catch exception = %@", [exception debugDescription]);
                output.resultCode = ERROR_CLIENT_PARSE_DATA;
            }
        }
        else{
            // for JSON handling
            if (returnJSONArray) {
                output.jsonDataArray = [dict objectForKey:RET_DATA];
            }else{
                output.jsonDataDict = [dict objectForKey:RET_DATA];
            }
        }
        return;
    };
    
    int format = returnPB ? FORMAT_PB : FORMAT_JSON;
    
    return (GameNetworkOutput*)[PPNetworkRequest uploadRequest:baseURL
                                                 imageDataDict:imageDict
                                                  postDataDict:dataDict
                                           constructURLHandler:constructURLHandler
                                               responseHandler:responseHandler
                                                  outputFormat:format
                                                        output:output
                                              progressDelegate:progressDelegate];
}

+ (GameNetworkOutput*)apiServerGetAndResponseJSON:(NSString *)method
                                       parameters:(NSDictionary *)parameters
                                    isReturnArray:(BOOL)isReturnArray
{
    return [self sendGetRequestWithBaseURL:API_SERVER_URL
                             method:method
                         parameters:parameters
                           returnPB:NO
                    returnJSONArray:isReturnArray];
}

+ (GameNetworkOutput*)apiServerGetAndResponsePB:(NSString *)method
                                     parameters:(NSDictionary *)parameters
{
    return [self sendGetRequestWithBaseURL:API_SERVER_URL
                             method:method
                         parameters:parameters
                           returnPB:YES
                    returnJSONArray:NO];
}

+ (GameNetworkOutput*)apiServerPostAndResponseJSON:(NSString *)method
                                       parameters:(NSDictionary *)parameters
                                          postData:(NSData*)postData
                                    isReturnArray:(BOOL)isReturnArray
{
    return [self sendPostRequestWithBaseURL:API_SERVER_URL
                                     method:method
                                 parameters:parameters
                                   postData:postData
                                   returnPB:NO
                            returnJSONArray:isReturnArray];
}

+ (GameNetworkOutput*)apiServerPostAndResponsePB:(NSString *)method
                                     parameters:(NSDictionary *)parameters
                                        postData:(NSData*)postData
{
    return [self sendPostRequestWithBaseURL:API_SERVER_URL
                                     method:method
                                 parameters:parameters
                                   postData:postData
                                   returnPB:YES
                            returnJSONArray:NO];
}

+ (GameNetworkOutput*)trafficApiServerGetAndResponseJSON:(NSString *)method
                                       parameters:(NSDictionary *)parameters
                                    isReturnArray:(BOOL)isReturnArray
{
    return [self sendGetRequestWithBaseURL:TRAFFIC_SERVER_URL
                             method:method
                         parameters:parameters
                           returnPB:NO
                    returnJSONArray:isReturnArray];
}

+ (GameNetworkOutput*)trafficApiServerGetAndResponsePB:(NSString *)method
                                     parameters:(NSDictionary *)parameters
{
    return [self sendGetRequestWithBaseURL:TRAFFIC_SERVER_URL
                             method:method
                         parameters:parameters
                           returnPB:YES
                    returnJSONArray:NO];
}

+ (GameNetworkOutput*)trafficApiServerPostAndResponseJSON:(NSString *)method
                                        parameters:(NSDictionary *)parameters
                                          postData:(NSData*)postData
                                     isReturnArray:(BOOL)isReturnArray
{
    return [self sendPostRequestWithBaseURL:TRAFFIC_SERVER_URL
                                     method:method
                                 parameters:parameters
                                   postData:postData
                                   returnPB:NO
                            returnJSONArray:isReturnArray];
}

+ (GameNetworkOutput*)trafficApiServerPostAndResponsePB:(NSString *)method
                                      parameters:(NSDictionary *)parameters
                                        postData:(NSData*)postData
{
    return [self sendPostRequestWithBaseURL:TRAFFIC_SERVER_URL
                                     method:method
                                 parameters:parameters
                                   postData:postData
                                   returnPB:YES
                            returnJSONArray:NO];
}

+ (GameNetworkOutput*)trafficApiServerUploadAndResponsePB:(NSString *)method
                                               parameters:(NSDictionary *)parameters
                                            imageDataDict:(NSDictionary *)imageDict
                                             postDataDict:(NSDictionary *)dataDict
                                         progressDelegate:(id)progressDelegate
{
    return [self uploadDataRequestWithBaseURL:TRAFFIC_SERVER_URL
                                       method:method
                                   parameters:parameters
                                imageDataDict:imageDict
                                 postDataDict:dataDict
                                     returnPB:YES
                              returnJSONArray:NO
                             progressDelegate:progressDelegate];
}

@end
