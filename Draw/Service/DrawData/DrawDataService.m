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
#import "FeedManager.h"
#import "MyPaintManager.h"
#import "PPConfigManager.h"
#import "UIImageExt.h"
#import "DrawFeed.h"
#import "Tutorial.pb.h"
#import "UserTutorialManager.h"
#import "UserTutorialService.h"
#import "UIImageUtil.h"
#import "PPGameNetworkRequest.h"
#import "PPConfigManager.h"

static DrawDataService* _defaultDrawDataService = nil;

@implementation DrawDataService

+ (DrawDataService *)defaultService{
    if (_defaultDrawDataService == nil) {
        _defaultDrawDataService = [[DrawDataService alloc] init];
    }
    return _defaultDrawDataService;
}

#define COMMIT_QUQUE_KEY @"COMMIT_QUQUE_KEY" 
- (NSOperationQueue *)commitQuque
{
    return [self getOperationQueue:COMMIT_QUQUE_KEY];
}

- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    NSOperationQueue *queue = [self commitQuque];
    [queue cancelAllOperations];
    
    [queue addOperationWithBlock: ^{
        CommonNetworkOutput* output = [GameNetworkRequest findDrawWithProtocolBuffer:SERVER_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *list = nil;
            
            if (output.resultCode == ERROR_SUCCESS){
                if ([output.responseData length] <= 0){
                    PPDebug(@"<findRecentDraw> but no draw data return");
                    return;
                }
                
                DataQueryResponse *travelResponse = [DataQueryResponse parseFromData:output.responseData];
                list = [travelResponse drawData];
            }
            if ([viewController respondsToSelector:@selector(didFindRecentDraw:result:)]){
                [viewController didFindRecentDraw:list result:output.resultCode];
            }
        });
    }];
}


- (void)matchDraw:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    
    
    NSOperationQueue *queue = [self commitQuque];
    [queue cancelAllOperations];
    
    [queue addOperationWithBlock: ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
        NSString *uid = [[UserManager defaultManager] userId];
        NSString *gender = [[UserManager defaultManager] gender];
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput* output = [GameNetworkRequest 
                                       matchDrawWithProtocolBuffer:TRAFFIC_SERVER_URL 
                                       userId:uid 
                                       gender:gender 
                                       lang:lang 
                                       type:1];;
        
        DrawFeed *feed = nil;
        NSInteger resultCode = [output resultCode];
        @try {

            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                NSArray *list = [response feed];
                PBFeed *pbFeed = ([list count] != 0) ? [list objectAtIndex:0] : nil;
                if (pbFeed && (pbFeed.actionType == FeedTypeDraw || pbFeed.actionType == FeedTypeDrawToUser)) {
                    
                    // new support in server
                    // add download feed draw data by data URL
                    if ([[pbFeed drawDataUrl] length] > 0){
                        NSData* data = [[FeedDownloadService defaultService]
                                            downloadDrawDataFile:[pbFeed drawDataUrl]
                                                        fileName:[pbFeed feedId]
                                        downloadProgressDelegate:viewController];
                        
                        if (data != nil){
                            // create PBDraw from data and rewrite pbFeed
                            PBDraw* pbDraw = [PBDraw parseFromData:data];
                            pbFeed = [[[PBFeed builderWithPrototype:pbFeed] setDrawData:pbDraw] build];
                            if (pbDraw != nil) {
                                [[FeedManager defaultManager] cachePBDraw:pbDraw forFeedId:pbFeed.feedId];
                            }
                        }
                        
                    }
                    feed = [[[DrawFeed alloc] initWithPBFeed:pbFeed] autorelease];
                }
                resultCode = [response resultCode];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<matchDraw> catch exception =%@", [exception description]);
            resultCode = ERROR_CLIENT_PARSE_DATA;

        }
        @finally {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{            
            if (viewController && [viewController respondsToSelector:@selector(didMatchDraw:result:)]) {
                [viewController didMatchDraw:feed result:resultCode];
            }  
        });
        
        [subPool drain];
    }];
}



- (void)matchOpus:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    
    
    NSOperationQueue *queue = [self commitQuque];
    [queue cancelAllOperations];
    
    [queue addOperationWithBlock: ^{
        
        // add by Benson
        NSAutoreleasePool *subPool = [[NSAutoreleasePool alloc] init];
        
        NSString *uid = [[UserManager defaultManager] userId];
        NSString *gender = [[UserManager defaultManager] gender];
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput* output = [GameNetworkRequest
                                       matchDrawWithProtocolBuffer:TRAFFIC_SERVER_URL
                                       userId:uid
                                       gender:gender
                                       lang:lang
                                       type:1];;
        
        DrawFeed *feed = nil;
        NSInteger resultCode = [output resultCode];
        @try {
            
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                NSArray *list = [response feed];
                PBFeed *pbFeed = ([list count] > 0) ? [list objectAtIndex:0] : nil;
                if (pbFeed != nil){
                    feed = [[[DrawFeed alloc] initWithPBFeed:pbFeed] autorelease];
                }
                resultCode = [response resultCode];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<matchDraw> catch exception =%@", [exception description]);
            resultCode = ERROR_CLIENT_PARSE_DATA;
            
        }
        @finally {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (viewController && [viewController respondsToSelector:@selector(didMatchDraw:result:)]) {
                [viewController didMatchDraw:feed result:resultCode];
            }
        });
        
        [subPool drain];
    }];
}



- (PBDraw*)buildPBDraw:(NSString*)userId
                  nick:(NSString *)nick
                avatar:(NSString *)avatar
        drawActionList:(NSArray*)drawActionList
              drawWord:(Word*)drawWord
              language:(LanguageType)language
                  size:(CGSize)size
          isCompressed:(BOOL)isCompressed
{
    PBDrawBuilder* builder = [[PBDrawBuilder alloc] init];
    [builder setUserId:userId];
    [builder setNickName:nick];
    [builder setAvatar:avatar];
    [builder setWord:[drawWord text]];
    [builder setLevel:[drawWord level]];
    [builder setLanguage:language];
    [builder setScore:[drawWord score]];
    
    [builder setCanvasSize:CGSizeToPBSize(size)];
    
    for (DrawAction* drawAction in drawActionList){
        PBDrawAction *action = [drawAction toPBDrawAction];
        [builder addDrawData:action];
    }
    [builder setVersion:[PPConfigManager currentDrawDataVersion]];
    [builder setIsCompressed:isCompressed];
    
    PBDraw* draw = [builder build];        
    [builder release];
    
    return draw;
}


- (void)newCreateOfflineDraw:(NSMutableArray*)drawActionList
                    image:(UIImage *)image
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language
                targetUid:(NSString *)targetUid
                contestId:(NSString *)contestId
                     desc:(NSString *)desc
                     size:(CGSize)size
                   layers:(NSArray *)layers
                       draft:(MyPaint *)draft
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;
{
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [PPConfigManager appId];
    NSString* signature = [[UserManager defaultManager] signature];
    
    //    PBDraw *draw = [self buildPBDraw:userId
    //                                nick:nick
    //                              avatar:avatar
    //                      drawActionList:drawActionList
    //                            drawWord:drawWord
    //                            language:language
    //                                size:size
    //                        isCompressed:NO];
    
    BOOL isCompressed = NO;
    
    NSData *drawData = [DrawAction buildPBDrawData:userId
                                              nick:nick
                                            avatar:avatar
                                    drawActionList:drawActionList
                                          drawWord:drawWord
                                          language:language
                                              size:size
                                      isCompressed:isCompressed
                                            layers:layers
                                             draft:draft];
    
    if ([drawData length] == 0){
        if ([viewController respondsToSelector:@selector(didCreateDraw:opusId:)]){
            [viewController didCreateDraw:ERROR_MEMORY opusId:nil];
        }
        return;
    }
    
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
                                                           signature:signature
                                                              gender:gender
                                                              wordId:drawWord.wordId
                                                                word:drawWord.text
                                                            wordType:drawWord.wordType
                                                               level:drawWord.level
                                                               score:drawWord.score
                                                                lang:language
                                                                data:drawData
                                                           imageData:imageData
                                                         bgImageData:nil
                                                           targetUid:targetUid
                                                           contestId:contestId
                                                                desc:desc
                                                               draft:draft
                                                           userStage:nil
                                                        userTutorial:nil
                                                        isCompressed:isCompressed
                                                    progressDelegate:viewController];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([viewController respondsToSelector:@selector(didCreateDraw:opusId:)]){
                NSString* opusId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
                [viewController didCreateDraw: output.resultCode opusId:opusId];
            }
        });
        NSString *actionId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
        if ([actionId length] != 0) {
            //store the draw action.
        }
    });
}


- (NSData*)createOfflineDraw:(NSMutableArray*)drawActionList
                    image:(UIImage *)image
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language 
                targetUid:(NSString *)targetUid 
                contestId:(NSString *)contestId
                     desc:(NSString *)desc
                     size:(CGSize)size
                   layers:(NSArray *)layers
                    draft:(MyPaint *)draft
                   userStage:(PBUserStage*)userStage
                userTutorial:(PBUserTutorial *)userTutorial
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;
{

    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [PPConfigManager appId];
    NSString* signature = [[UserManager defaultManager] signature];    

    BOOL isCompressed = NO;
    
    NSData *drawData = [DrawAction buildPBDrawData:userId
                                nick:nick
                              avatar:avatar
                      drawActionList:drawActionList
                            drawWord:drawWord
                            language:language
                                size:size
                        isCompressed:isCompressed
                                layers:layers
                                 draft:draft];
    
    if ([drawData length] == 0){
        if ([viewController respondsToSelector:@selector(didCreateDraw:opusId:)]){
            [viewController didCreateDraw:ERROR_MEMORY opusId:nil];
        }        
        return nil;
    }
    
    NSData *imageData = nil;
    if (image) {
        imageData = [image data];
    }
    
    NSData* bgImageData = nil;
    if (draft.bgImage){
        bgImageData = UIImagePNGRepresentation(draft.bgImage); // make sure to upload PNG image here
    }
    
    int opusScore = [draft.score intValue];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest createOpus:TRAFFIC_SERVER_URL
                                                               appId:appId 
                                                              userId:userId 
                                                                nick:nick 
                                                              avatar:avatar
                                                           signature:signature
                                                              gender:gender
                                                              wordId:drawWord.wordId
                                                                word:drawWord.text
                                                            wordType:drawWord.wordType
                                                               level:drawWord.level
                                                               score:drawWord.score
                                                                lang:language                                      
                                                                data:drawData
                                                           imageData:imageData
                                                         bgImageData:bgImageData
                                                           targetUid:targetUid 
                                                           contestId:contestId
                                                                desc:desc
                                                               draft:draft
                                                           userStage:userStage
                                                        userTutorial:userTutorial
                                                        isCompressed:isCompressed
                                                    progressDelegate:viewController];

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *actionId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
            
            int totalCount = [[output.jsonDataDict objectForKey:PARA_TOTAL_COUNT] intValue];
            int defeatCount = [[output.jsonDataDict objectForKey:PARA_TOTAL_DEFEAT] intValue];
            
            NSString* bestOpusId = [output.jsonDataDict objectForKey:PARA_BEST_OPUS_ID];
            int bestOpusScore = [[output.jsonDataDict objectForKey:PARA_BEST_SCORE] intValue];

            NSString* lastOpusId = [output.jsonDataDict objectForKey:PARA_LATEST_OPUS_ID];
            int lastOpusScore = [[output.jsonDataDict objectForKey:PARA_LATEST_SCORE] intValue];
            
            if (userStage){

                PBUserStage* newUserStage = userStage;
                PBUserTutorial* newUserTutorial = userTutorial;
                if (output.resultCode == 0){
                    
                    // update current user stage status
                    PBUserStageBuilder* userStageBuilder = [PBUserStage builderWithPrototype:userStage];
                    [userStageBuilder setLastOpusId:lastOpusId];
                    [userStageBuilder setLastScore:lastOpusScore];
                    [userStageBuilder setBestOpusId:bestOpusId];
                    [userStageBuilder setBestScore:bestOpusScore];
                    [userStageBuilder setTotalCount:totalCount];
                    [userStageBuilder setDefeatCount:defeatCount];
                    
                    newUserStage = [userStageBuilder build];
                    PBUserTutorial* retUT = [[UserTutorialManager defaultManager] updateUserStage:newUserStage
                                                                                        utLocalId:userTutorial.localId]; // update local user stage status
                    if (retUT){
                        newUserTutorial = retUT;
                    }
                    
                    // for conquer draw result update
                    if ([[UserTutorialManager defaultManager] isPass:opusScore]){
                        if (userStage.stageIndex == userTutorial.currentStageIndex){
                            // pass this stage, need to update user tutorial to next stage index
                            retUT = [[UserTutorialService defaultService] passCurrentStage:newUserTutorial];
                            if (retUT){
                                newUserTutorial = retUT;
                            }
                        }
                    }
                }
                
                if ([viewController respondsToSelector:@selector(didCreateLearnDraw:opusId:userStage:userTutorial:)]){
                    [viewController didCreateLearnDraw:output.resultCode
                                                opusId:actionId
                                             userStage:newUserStage
                                          userTutorial:newUserTutorial];
                }
            }
            else{
                if ([viewController respondsToSelector:@selector(didCreateDraw:opusId:)]){
                    [viewController didCreateDraw: output.resultCode opusId:actionId];
                }
            }
        });
    });
    
    return drawData;
}

- (void)guessDraw:(NSArray *)guessWords 
           opusId:(NSString *)opusId 
   opusCreatorUid:(NSString *)opusCreatorUid
        isCorrect:(BOOL)isCorrect 
            score:(NSInteger)score
         category:(PBOpusCategoryType)category
         delegate:(PPViewController<DrawDataServiceDelegate>*)viewController
{
    
    if (isCorrect) {
        [[UserManager defaultManager] guessCorrectOpus:opusId];        
    }
    
    NSString* userId = [[UserManager defaultManager] userId];
    NSString* nick = [[UserManager defaultManager] nickName];
    NSString* gender = [[UserManager defaultManager] gender];
    NSString* avatar = [[UserManager defaultManager] avatarURL];
    NSString* appId = [PPConfigManager appId];    
    
    NSString *words = [guessWords componentsJoinedByString:@":"];
    int vip = [[UserManager defaultManager] isVip] ? [UserManager defaultManager].pbUser.vip : 0;
    
    
    PPDebug(@"<guessDraw> opusId=%@ creatorUserId=%@ score=%d", opusId, opusCreatorUid, score);    
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
                                                              words:words
                                                           category:category
                                                                vip:vip];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSInteger resultCode = output.resultCode;
            
            if ([viewController respondsToSelector:@selector(didGuessOfflineDraw:)]){
                [viewController didGuessOfflineDraw:resultCode];
            }            
        });
    });

}

- (void)savePaintWithPBDraw:(DrawFeed*)feed
                 pbDrawData:(NSData*)pbDrawData
                      image:(UIImage*)image
                   delegate:(id<DrawDataServiceDelegate>)delegate
{
    [self savePaintWithPBDraw:feed
                   pbDrawData:pbDrawData
                        image:image
                      isDraft:NO
                     delegate:delegate];
}

- (void)savePaintWithPBDraw:(DrawFeed*)feed
                 pbDrawData:(NSData*)pbDrawData
                      image:(UIImage*)image
                    isDraft:(BOOL)isDraft
                   delegate:(id<DrawDataServiceDelegate>)delegate;
{
    if ([pbDrawData length] == 0){
        PPDebug(@"<savePaintWithPBDraw>data is nil.");
        if (delegate && [delegate respondsToSelector:@selector(didSaveOpus:)]) {
            [delegate didSaveOpus:NO];
        }
        return;
    }
    else if (image == nil){
        PPDebug(@"<savePaintWithPBDraw>image is nil.");
        if (delegate && [delegate respondsToSelector:@selector(didSaveOpus:)]) {
            [delegate didSaveOpus:NO];
        }
        return;
    }
    
    if (isDraft){
        MyPaint* draft = [[MyPaintManager defaultManager] createDraftPaintWithImage:image
                                                                      pbDrawData:pbDrawData
                                                                            feed:feed];
        if (delegate && [delegate respondsToSelector:@selector(didSaveDraftOpus:)]) {
            [delegate didSaveDraftOpus:draft];
        }
    }
    else{
        BOOL result = [[MyPaintManager defaultManager] createMyPaintWithImage:image
                                                                   pbDrawData:pbDrawData
                                                                         feed:feed];
        if (delegate && [delegate respondsToSelector:@selector(didSaveOpus:)]) {
            [delegate didSaveOpus:result];
        }
    }
}


- (BOOL)savePaintWithPBDraw:(PBDraw*)pbDraw
                      image:(UIImage*)image
                   delegate:(id<DrawDataServiceDelegate>)delegate
{
    if ([pbDraw.drawData count] == 0) {
        PPDebug(@"<savePaintWithPBDraw>:actionList has no object");
        return NO;
    }else if(image == nil){
        PPDebug(@"<savePaintWithPBDraw>image is nil.");
        return NO;
    }
    
    PPDebug(@"<savePaintWithPBDraw>");
    BOOL result = [[MyPaintManager defaultManager] createMyPaintWithImage:image
                                                               pbDraw:pbDraw];

    return result;
}

- (BOOL)savePaintWithPBDrawData:(NSData*)pbDrawData
                          image:(UIImage*)image
                           word:(NSString*)word
                         opusId:(NSString*)opusId
{
    if (pbDrawData == nil) {
        PPDebug(@"<savePaintWithPBDrawData>:pbDrawData is nil");
        return NO;
    }else if(image == nil){
        PPDebug(@"<savePaintWithPBDrawData>image is nil.");
        return NO;
    }
    
    PPDebug(@"<savePaintWithPBDrawData>");
    BOOL result = [[MyPaintManager defaultManager] createMyPaintWithImage:image
                                                               pbDrawData:pbDrawData
                                                                     word:word
                                                                   opusId:opusId];
    
    return result;
}




@end
