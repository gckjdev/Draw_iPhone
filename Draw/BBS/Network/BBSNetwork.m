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
                                 gameId:(NSString *)gameId
                               language:(int)language
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBSBOARD_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_LANGUAGE intValue:language];
        str = [str stringByAddQueryParameter:PARA_GAME_ID value:gameId];
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
                             bonus:(NSInteger)bonus
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
        str = [str stringByAddQueryParameter:PARA_BONUS intValue:bonus];
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

    NSMutableDictionary *imageDict = [NSMutableDictionary dictionaryWithCapacity:2];
    if (drawImage) {
        [imageDict setObject:drawImage forKey:PARA_DRAW_IMAGE];
    }
    if (image) {
        [imageDict setObject:image forKey:PARA_IMAGE];
    }

    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];

}


+ (CommonNetworkOutput*)getPostList:(NSString*)baseURL
                              appId:(NSString*)appId
                         deviceType:(int)deviceType
                             userId:(NSString*)userId
                          targetUid:(NSString*)targetUid
                            boardId:(NSString*)boardId
                          rangeType:(NSInteger)rangeType
                             offset:(NSInteger)offset
                              limit:(NSInteger)limit;

{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBSPOST_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUid];
        str = [str stringByAddQueryParameter:PARA_BOARDID value:boardId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_RANGETYPE intValue:rangeType];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_LIMIT intValue:limit];
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


+ (CommonNetworkOutput*)createAction:(NSString*)baseURL
                               appId:(NSString*)appId
                          deviceType:(int)deviceType
//user info
                              userId:(NSString*)userId
                            nickName:(NSString*)nickName
                              gender:(NSString*)gender
                              avatar:(NSString*)avatar
//source
                        sourcePostId:(NSString*)sourcePostId
                       sourcePostUid:(NSString *)sourcePostUid
                       sourceAtionId:(NSString*)sourceAtionId
                     sourceActionUid:(NSString *)sourceActionUid
                sourceActionNickName:(NSString *)sourceActionNickName
                    sourceActionType:(NSInteger)sourceActionType
                           briefText:(NSString *)briefText
//data
                         contentType:(NSInteger)contentType
                          actionType:(NSInteger)actionType
                                text:(NSString *)text
                               image:(NSData *)image
                            drawData:(NSData *)drawData
                           drawImage:(NSData *)drawImage
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_CREATE_BBS_ACTION];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        
        //user
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:nickName];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:avatar];
        str = [str stringByAddQueryParameter:PARA_GENDER value:gender];
        
        //source
        str = [str stringByAddQueryParameter:PARA_POSTID value:sourcePostId];
        str = [str stringByAddQueryParameter:PARA_ACTIONID value:sourceAtionId];
        str = [str stringByAddQueryParameter:PARA_POST_UID value:sourcePostUid];
        str = [str stringByAddQueryParameter:PARA_ACTION_UID value:sourceActionUid];
        str = [str stringByAddQueryParameter:PARA_ACTION_NICKNAME value:sourceActionNickName];
        
        str = [str stringByAddQueryParameter:PARA_SOURCE_ACTION_TYPE intValue:sourceActionType];
        str = [str stringByAddQueryParameter:PARA_BRIEF_TEXT value:briefText];
        
        //content
        str = [str stringByAddQueryParameter:PARA_CONTENT_TYPE intValue:contentType];
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:actionType];
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
    
    NSMutableDictionary *imageDict = [NSMutableDictionary dictionaryWithCapacity:2];
    if (drawImage) {
        [imageDict setObject:drawImage forKey:PARA_DRAW_IMAGE];
    }
    if (image) {
        [imageDict setObject:image forKey:PARA_IMAGE];
    }
    
    return [PPNetworkRequest uploadRequest:baseURL
                             imageDataDict:imageDict
                              postDataDict:dataDict
                       constructURLHandler:constructURLHandler
                           responseHandler:responseHandler
                                    output:output];
    
    
}
+ (CommonNetworkOutput*)getActionList:(NSString*)baseURL
                                appId:(NSString *)appId
                           deviceType:(NSInteger)deviceType
                               userId:(NSString *)userId
                            targetUid:(NSString *)targetUid
                               postId:(NSString *)postId
                           actionType:(NSInteger)actionType
                               offset:(NSInteger)offset
                                limit:(NSInteger)limit
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBSACTION_LIST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_TARGETUSERID value:targetUid];
        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
        str = [str stringByAddQueryParameter:PARA_ACTION_TYPE intValue:actionType];
        str = [str stringByAddQueryParameter:PARA_OFFSET intValue:offset];
        str = [str stringByAddQueryParameter:PARA_LIMIT intValue:limit];
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


+ (CommonNetworkOutput*)deleteBBSPost:(NSString*)baseURL
                                appId:(NSString *)appId
                           deviceType:(NSInteger)deviceType
                               userId:(NSString *)userId
                               postId:(NSString *)postId
                              boardId:(NSString *)boardId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETE_BBSPOST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
        str = [str stringByAddQueryParameter:PARA_BOARDID value:boardId];
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];      
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_JSON
                                  output:output];    

}

+ (CommonNetworkOutput*)deleteBBSAction:(NSString*)baseURL
                                  appId:(NSString *)appId
                             deviceType:(NSInteger)deviceType
                                 userId:(NSString *)userId
                               actionId:(NSString *)actionId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_DELETE_BBSACTION];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_ACTIONID value:actionId];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];      
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_JSON
                                  output:output];

}

+ (CommonNetworkOutput*)payReward:(NSString*)baseURL
                           userId:(NSString *)userId
                            appId:(NSString *)appId
                       deviceType:(NSInteger)deviceType
//post info
                           postId:(NSString *)postId
//action info
                         actionId:(NSString *)actionId
                        actionUid:(NSString *)actionUid
                       actionNick:(NSString *)actionNick
                     actionGender:(NSString *)actionGender
                     actionAvatar:(NSString *)actionAvatar
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_PAY_BBS_REWARD];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_ACTIONID value:actionId];

        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
        str = [str stringByAddQueryParameter:PARA_ACTION_UID value:actionUid];
        str = [str stringByAddQueryParameter:PARA_NICKNAME value:actionNick];
        str = [str stringByAddQueryParameter:PARA_GENDER value:actionGender];
        str = [str stringByAddQueryParameter:PARA_AVATAR value:actionAvatar];
        
        return str;
    };
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:RET_DATA];
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                            outputFormat:FORMAT_JSON
                                  output:output];
}


+ (CommonNetworkOutput*)getBBSPost:(NSString*)baseURL
                             appId:(NSString *)appId
                        deviceType:(NSInteger)deviceType
                            userId:(NSString *)userId
                            postId:(NSString *)postId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBSPOST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
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

+ (CommonNetworkOutput*)getBBSDrawData:(NSString*)baseURL
                                 appId:(NSString *)appId
                            deviceType:(NSInteger)deviceType
                                userId:(NSString *)userId
                                postId:(NSString *)postId
                              actionId:(NSString *)actionId
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_GET_BBS_DRAWDATA];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
        str = [str stringByAddQueryParameter:PARA_ACTIONID value:actionId];
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


+ (CommonNetworkOutput*)editBBSPost:(NSString*)baseURL
                              appId:(NSString *)appId
                         deviceType:(NSInteger)deviceType
                             userId:(NSString *)userId
                             postId:(NSString *)postId
                            boardId:(NSString *)boardId
                             status:(int)status
                               info:(NSDictionary *)info //for the future
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];
        
        str = [str stringByAddQueryParameter:METHOD value:METHOD_EDIT_BBS_POST];
        str = [str stringByAddQueryParameter:PARA_APPID value:appId];
        str = [str stringByAddQueryParameter:PARA_USERID value:userId];
        str = [str stringByAddQueryParameter:PARA_DEVICETYPE intValue:deviceType];
        str = [str stringByAddQueryParameter:PARA_POSTID value:postId];
        str = [str stringByAddQueryParameter:PARA_BOARDID value:boardId];
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
                            outputFormat:FORMAT_JSON
                                  output:output];
    
}

@end


