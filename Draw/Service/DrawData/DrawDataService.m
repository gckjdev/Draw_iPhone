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
#import "Feed.h"
#import "MyPaintManager.h"
#import "ConfigManager.h"

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
            Feed *feed = nil;
            NSInteger resultCode = [output resultCode];            
            if (output.resultCode == ERROR_SUCCESS) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                NSArray *list = [response feedList];
                PBFeed *pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                if (pbFeed) {
                    feed = [[[Feed alloc] initWithPBFeed:pbFeed] autorelease];
                }
                resultCode = [response resultCode];
            }
            if (viewController && [viewController respondsToSelector:@selector(didMatchDraw:result:)]) {
                [viewController didMatchDraw:feed result:resultCode];
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
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language 
                targetUid:(NSString *)targetUid
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
                                                                data:[draw data] 
                                                           targetUid:targetUid];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([viewController respondsToSelector:@selector(didCreateDraw:)]){
                [viewController didCreateDraw: output.resultCode];
            }
        });
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

// save draw data locally
- (void)saveActionList:(NSArray *)actionList 
                userId:(NSString*)userId 
              nickName:(NSString*)nickName 
             isMyPaint:(BOOL)isMyPaint
                  word:(NSString*)word
                 image:(UIImage*)image
        viewController:(PPViewController*)viewController
{
    
    if (actionList.count == 0) {
        PPDebug(@"actionList has no object");        
    }
    
    if ([DrawAction isDrawActionListBlank:actionList]) {
        return;
    }
    time_t aTime = time(0);
    NSString* imageName = [NSString stringWithFormat:@"%d.png", aTime];
    if (image!=nil) 
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        if (queue == NULL){
            return;
        }
        
        dispatch_async(queue, ^{
            //此处首先指定了图片存取路径（默认写到应用程序沙盒 中）
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            if (!paths) {
                PPDebug(@"Document directory not found!");
            }
            //并给文件起个文件名
            NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
            //此处的方法是将图片写到Documents文件中 如果写入成功会弹出一个警告框,提示图片保存成功
            NSData* imageData = UIImagePNGRepresentation(image);
            BOOL result=[imageData writeToFile:uniquePath atomically:YES];
            PPDebug(@"<DrawGameService> save image to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {                    
                    NSData* drawActionListData = [NSKeyedArchiver archivedDataWithRootObject:actionList];
                    [[MyPaintManager defaultManager ] createMyPaintWithImage:uniquePath 
                                                                        data:drawActionListData 
                                                                  drawUserId:userId
                                                            drawUserNickName:nickName 
                                                                    drawByMe:isMyPaint
                                                                    drawWord:word];
                    
                    [viewController popupMessage:NSLS(@"kSaveImageOK") title:nil];
                }
            });
        });
    }
    
}


@end
