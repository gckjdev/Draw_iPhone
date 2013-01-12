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
#import "Draw.h"
#import "DrawManager.h"
#import "FeedManager.h"
#import "MyPaintManager.h"
#import "ConfigManager.h"
#import "UIImageExt.h"

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
                if ([output.responseData length] <= 0){
                    PPDebug(@"<findRecentDraw> but no draw data return");
                    return;
                }
                
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
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       matchDrawWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:uid 
                                       gender:gender 
                                       lang:lang 
                                       type:1];;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            DrawFeed *feed = nil;
            NSInteger resultCode = [output resultCode];            
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                NSArray *list = [response feedList];
                PBFeed *pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                if (pbFeed && (pbFeed.actionType == FeedTypeDraw || pbFeed.actionType == FeedTypeDrawToUser)) {
                    feed = [[[DrawFeed alloc] initWithPBFeed:pbFeed] autorelease];
//                    [feed parseDrawData:pbFeed];
                }
                resultCode = [response resultCode];
            }
            if (viewController && [viewController respondsToSelector:@selector(didMatchDraw:result:)]) {
                [viewController didMatchDraw:feed result:resultCode];
            }  
        });
        //TODO store feed draw data.
    });    
}


- (PBDrawAction *)buildPBDrawAction:(DrawAction *)drawAction
{
    PBDrawAction_Builder* dataBuilder = [[PBDrawAction_Builder alloc] init];
    
    [dataBuilder setType:[drawAction type]];

    NSArray *pointList = nil;
    if ([DeviceDetection isIPAD]) {
        pointList = [drawAction intPointListWithXScale:IPAD_WIDTH_SCALE yScale:IPAD_HEIGHT_SCALE];
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
                  nick:(NSString *)nick 
                avatar:(NSString *)avatar
        drawActionList:(NSArray*)drawActionList
              drawWord:(Word*)drawWord
              language:(LanguageType)language
{
    PBDraw_Builder* builder = [[PBDraw_Builder alloc] init];
    [builder setUserId:userId];
    [builder setNickName:nick];
    [builder setAvatar:avatar];
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
                    image:(UIImage *)image
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language 
                targetUid:(NSString *)targetUid 
                contestId:(NSString *)contestId
                     desc:(NSString *)desc
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;
{

    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    PBDraw* draw = [self buildPBDraw:userId 
                                nick:nick 
                              avatar:avatar
                      drawActionList:drawActionList
                            drawWord:drawWord 
                            language:language];
    
    NSData *imageData = nil;
    if (image) {
        imageData = [image data];
    }
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest createOpus:TRAFFIC_SERVER_URL
                                                               appId:appId 
                                                              userId:userId 
                                                                nick:nick 
                                                              avatar:avatar 
                                                              gender:gender
                                                              wordId:drawWord.wordId
                                                                word:drawWord.text
                                                            wordType:drawWord.wordType
                                                               level:drawWord.level
                                                               score:drawWord.score
                                                                lang:language                                      
                                                                data:[draw data] 
                                                           imageData:imageData 
                                                           targetUid:targetUid 
                                                           contestId:contestId
                                                                desc:desc];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didCreateDraw:)]){
                [viewController didCreateDraw: output.resultCode];
            }
        });
        NSString *actionId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
        if ([actionId length] != 0) {
            //store the draw action.
            
        }
    });
}

- (void)guessDraw:(NSArray *)guessWords 
           opusId:(NSString *)opusId 
   opusCreatorUid:(NSString *)opusCreatorUid
        isCorrect:(BOOL)isCorrect 
            score:(NSInteger)score
         delegate:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [ConfigManager appId];
    
    NSString *words = [guessWords componentsJoinedByString:@":"];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest guessOpus:TRAFFIC_SERVER_URL 
                                                              appId:appId 
                                                             userId:userId 
                                                               nick:nick 
                                                             avatar:avatar 
                                                             gender:gender 
                                                             opusId:opusId 
                                                     opusCreatorUId:opusCreatorUid
                                                          isCorrect:isCorrect 
                                                              score:score 
                                                              words:words];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger resultCode = output.resultCode;
            
            if ([viewController respondsToSelector:@selector(didGuessOfflineDraw:)]){
                [viewController didGuessOfflineDraw:resultCode];
            }
        });
    });

}



- (void)savePaintWithPBDraw:(PBDraw*)pbDraw
                      image:(UIImage*)image
                   delegate:(id<DrawDataServiceDelegate>)delegate;
{
    if ([pbDraw.drawDataList count] == 0) {
        PPDebug(@"<savePaintWithPBDraw>:actionList has no object");
        return;
    }else if(image == nil){
        PPDebug(@"<savePaintWithPBDraw>image is nil.");
        return;
    }
    
    dispatch_async(workingQueue, ^{
        BOOL result = [[MyPaintManager defaultManager] createMyPaintWithImage:image
                                                                   pbDrawData:pbDraw];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didSaveOpus:)]) {
                [delegate didSaveOpus:result];
            }
        });
    });
}


@end
