//
//  DrawDataService.m
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "DrawDataService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "Paint.h"
#import "GameNetworkConstants.h"
#import "DrawUtils.h"
#import "DeviceDetection.h"
static DrawDataService* _defaultDrawDataService = nil;

@implementation DrawDataService

+ (DrawDataService *)defaultService{
    if (_defaultDrawDataService == nil) {
        _defaultDrawDataService = [[DrawDataService alloc] init];
    }
    return _defaultDrawDataService;
}


- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest findDrawWithProtocolBuffer:SERVER_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *list = nil;
            
            if (output.resultCode == ERROR_SUCCESS){
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                list = [travelResponse drawDataList];
            }
            if ([viewController respondsToSelector:@selector(didFindRecentDraw:result:)]){
                [viewController didFindRecentDraw:list result:output.resultCode];
            }
        });
    });
}


- (void)matchDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    dispatch_async(workingQueue, ^{
        
        NSString *uid = [[UserManager defaultManager] userId];
        NSString *gender = [[UserManager defaultManager] gender];
        
        CommonNetworkOutput* output = [GameNetworkRequest matchDrawWithProtocolBuffer:TRAFFIC_SERVER_URL userId:uid gender:gender type:0];;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *list = nil;
            
            if (output.resultCode == ERROR_SUCCESS){
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                list = [response drawDataList];
                [response resultCode];
            }
            if ([viewController respondsToSelector:@selector(didFindRecentDraw:result:)]){
                [viewController didFindRecentDraw:list result:output.resultCode];
            }
        });
    });    
}


- (PBDrawAction *)buildPBDrawAction:(DrawAction *)drawAction
{
    PBDrawAction_Builder* dataBuilder = [[PBDrawAction_Builder alloc] init];
    
    [dataBuilder setType:[drawAction type]];

    NSArray *pointList = nil;
    if ([DeviceDetection isIPAD]) {
        pointList = [drawAction intPointListWithXScale:IPAD_WIDTH_SCALE yScale:IPAD_WIDTH_SCALE];
    }else{
        pointList = [drawAction intPointListWithXScale:1 yScale:1];
    }

    [dataBuilder addAllPoints:pointList];
    
    CGFloat width = [[drawAction paint] width];
    if ([DeviceDetection isIPAD]) {
        width /= 2;
    }
    [dataBuilder setWidth:width];
    NSInteger intColor  = [DrawUtils compressDrawColor:drawAction.paint.color];    
    [dataBuilder setColor:intColor];
    
    [dataBuilder setPenType:[[drawAction paint] penType]];
    
    PBDrawAction *action = [dataBuilder build];
    [dataBuilder release];    
    return action;

}

- (PBDraw*)buildPBDraw:(NSString*)userId
        drawActionList:(NSArray*)drawActionList
              drawWord:(Word*)drawWord
              language:(LanguageType)language
{
    PBDraw_Builder* builder = [[PBDraw_Builder alloc] init];
    [builder setUserId:userId];
    [builder setWord:[drawWord text]];
    [builder setLevel:[drawWord level]];
    [builder setLanguage:language];
    for (DrawAction* drawAction in drawActionList){
        PBDrawAction *action = [self buildPBDrawAction:drawAction];
        [builder addDrawData:action];
    }
    
    PBDraw* draw = [builder build];        
    [builder release];
    
    return draw;
}

- (void)createOfflineDraw:(NSArray*)drawActionList
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = @"";
    PBDraw* draw = [self buildPBDraw:userId
                      drawActionList:drawActionList
                            drawWord:drawWord 
                            language:language];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest createOpus:TRAFFIC_SERVER_URL
                                                               appId:appId 
                                                              userId:userId 
                                                                nick:nick 
                                                              avatar:avatar 
                                                              gender:gender 
                                                                word:drawWord.text 
                                                               level:drawWord.level 
                                                                lang:language 
                                                                data:[draw data]];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didCreateDraw:)]){
                [viewController didCreateDraw: output.resultCode];
            }
        });
    });

    
}

@end
