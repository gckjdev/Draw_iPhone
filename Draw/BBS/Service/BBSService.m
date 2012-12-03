//
//  BBSService.m
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "BBSService.h"
#import "BBSNetwork.h"

#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "UserManager.h"
#import "GameNetworkConstants.h"
#import "ConfigManager.h"
#import "DrawDataService.h"
#import "UIImageExt.h"

#import "DrawAction.h"
#import "DrawManager.h"


BBSService *_staticBBSService;

@implementation BBSService

+ (id)defaultService
{
    if (_staticBBSService == nil) {
        _staticBBSService = [[BBSService alloc] init];
    }
    return _staticBBSService;
}

#pragma mark - checking method

- (NSInteger)checkFrequent
{
//    return ERROR_SUCCESS;
    
    BBSManager *_bbsManager = [BBSManager defaultManager];
    if ([_bbsManager isCreationFrequent]) {
        PPDebug(@"<checkWithText> to frequent!!!");
        return ERROR_BBS_TEXT_TOO_FREQUENT;
    }else{
        return ERROR_SUCCESS;
    }
}

- (NSInteger)checkWithText:(NSString *)text contentType:(BBSPostContentType)type
{
    BBSManager *_bbsManager = [BBSManager defaultManager];
    if (type == ContentTypeText) {
        if ([text length] < [_bbsManager textMinLength]) {
            PPDebug(@"<checkWithText> text(%@) to short!!!",text);
            return ERROR_BBS_TEXT_TOO_SHORT;
        }else if ([text length] > [_bbsManager textMaxLength]){
            PPDebug(@"<checkWithText> text(%@) to long!!!",text);
            return ERROR_BBS_TEXT_TOO_LONG;
        }
    }
    return ERROR_SUCCESS;
}


- (NSString *)defaultTextForContentType:(BBSPostContentType)type
{
    if (ContentTypeDraw == type) {
        return NSLS(@"kDraw");
    }
    if (ContentTypeImage == type) {
        return NSLS(@"kImage");
    }
    return nil;
}

#pragma mark - pb data builder

- (PBBBSUser *)buildPBBBSUserWithUserId:(NSString*)userId
                               nickName:(NSString*)nickName
                                 gender:(NSString*)gender
                                 avatar:(NSString*)avatar
{
    PBBBSUser_Builder *builder = [[PBBBSUser_Builder alloc] init];
    [builder setUserId:userId];
    [builder setNickName:nickName];
    [builder setGender:([gender isEqualToString:@"m"] ? YES : NO)];
    [builder setAvatar:avatar];
    PBBBSUser *user = [builder build];
    [builder release];
    return user;
}


- (PBBBSContent *)buildPBBBSContentWithType:(NSInteger)type
                                       text:(NSString *)text                                imageUrl:(NSString *)imageUrl
                              thumbImageUrl:(NSString *)thumbImageUrl
                               drawImageUrl:(NSString *)drawImageUrl
                          drawImageThumbUrl:(NSString *)drawImageThumbUrl
{
    PBBBSContent_Builder *builder = [[PBBBSContent_Builder alloc] init];
    [builder setType:type];
    [builder setText:text];
    [builder setImageUrl:imageUrl];
    [builder setThumbImageUrl:thumbImageUrl];
    [builder setDrawImageUrl:drawImageUrl];
    [builder setDrawThumbUrl:drawImageThumbUrl];
    PBBBSContent *content = [builder build];
    [builder release];
    return content;
}

- (PBBBSReward *)buildPBBBSRewardWithBounus:(NSInteger)bonus
{
    if (bonus <= 0) {
        return nil;
    }
    PBBBSReward_Builder *builder = [[PBBBSReward_Builder alloc] init];
    [builder setBonus:bonus];
    [builder setStatus:RewardStatusOn];
    PBBBSReward *reward = [builder build];
    [builder release];
    return reward;
}

- (PBBBSPost *)buildPBBBSPostWithPostId:(NSString *)postId
                                  appId:(NSString*)appId
                             deviceType:(int)deviceType
                                 userId:(NSString*)userId
                               nickName:(NSString*)nickName
                                 gender:(NSString*)gender
                                 avatar:(NSString*)avatar
                                boradId:(NSString*)boardId
                            contentType:(NSInteger)contentType
                                   text:(NSString *)text
                               imageUrl:(NSString *)imageUrl
                          thumbImageUrl:(NSString *)thumbImageUrl
                           drawImageUrl:(NSString *)drawImageUrl
                      drawImageThumbUrl:(NSString *)drawImageThumbUrl
                                  bonus:(NSInteger)bonus
{
    PBBBSPost_Builder *builder = [[PBBBSPost_Builder alloc] init];
    [builder setPostId:postId];
    [builder setBoardId:boardId];
    [builder setAppId:appId];
    [builder setDeviceType:deviceType];
    [builder setReplyCount:0];
    [builder setSupportCount:0];
    NSInteger time = [[NSDate date] timeIntervalSince1970];
    [builder setCreateDate:time];
    [builder setModifyDate:time];
    
    PBBBSUser *user = [self buildPBBBSUserWithUserId:userId
                                            nickName:nickName
                                              gender:gender
                                              avatar:avatar];
    [builder setCreateUser:user];
    PBBBSContent *content = [self buildPBBBSContentWithType:contentType
                                                       text:text
                                                   imageUrl:imageUrl
                                              thumbImageUrl:thumbImageUrl
                                               drawImageUrl:drawImageUrl
                                          drawImageThumbUrl:drawImageThumbUrl];
    [builder setContent:content];
    
    PBBBSReward *reward = [self buildPBBBSRewardWithBounus:bonus];
    if (reward) {
        [builder setReward:reward];        
    }

    
    PBBBSPost *post = [builder build];
    [builder release];
    return post;
}

- (PBBBSDraw *)buildBBSDraw:(NSArray *)drawActionList
{
    PBBBSDraw *bbsDraw = nil;
    NSMutableArray *pbDrawActionList = [NSMutableArray arrayWithCapacity:drawActionList.count];
    for (DrawAction *action in drawActionList) {
        PBDrawAction * pbAction = [[DrawDataService defaultService]
                                   buildPBDrawAction:action];
        [pbDrawActionList addObject:pbAction];
    }
    if ([pbDrawActionList count] != 0) {
        PBBBSDraw_Builder *builder = [[PBBBSDraw_Builder alloc] init];
        [builder addAllDrawActionList:pbDrawActionList];
        bbsDraw = [builder build];
        [builder release];
    }
    return bbsDraw;
}


- (PBBBSActionSource *)buildActionSourceWithPostId:(NSString *)postId
                                           postUid:(NSString *)postUid
                                          actionId:(NSString *)actionId
                                         actionUid:(NSString *)actionUid
                              sourceActionNickName:(NSString *)sourceActionNickName
                                        actionType:(BBSActionType)actionType
                                         briefText:(NSString *)briefText
{
    PBBBSActionSource_Builder *builder = [[PBBBSActionSource_Builder alloc] init];
    builder.postId = postId;
    [builder setPostUid:postUid];
    if ([actionId length] > 0) {
        [builder setActionId:actionId];
        [builder setActionUid:actionUid];
        [builder setActionNick:sourceActionNickName];
        [builder setActionType:actionType];
    }
    [builder setBriefText:briefText];
    PBBBSActionSource *source = [builder build];
    [builder release];
    return source;
}

- (PBBBSAction *)buildActionWithActionId:(NSString *)actionId
                                    type:(BBSActionType)type
                                   appId:(NSString*)appId
                              deviceType:(int)deviceType
                                  userId:(NSString*)userId
                                nickName:(NSString*)nickName
                                  gender:(NSString*)gender
                                  avatar:(NSString*)avatar
                              createDate:(NSDate *)createDate
                              replyCount:(NSInteger)replyCount
                             contentType:(NSInteger)contentType
                                    text:(NSString *)text
                                imageUrl:(NSString *)imageUrl
                           thumbImageUrl:(NSString *)thumbImageUrl
                            drawImageUrl:(NSString *)drawImageUrl
                       drawImageThumbUrl:(NSString *)drawImageThumbUrl
                            sourcePostId:(NSString *)sourcePostId
                           sourcePostUid:(NSString *)sourcePostUid
                          sourceActionId:(NSString *)sourceActionId
                         sourceActionUid:(NSString *)sourceActionUid
                    sourceActionNickName:(NSString *)sourceActionNickName
                        sourceActionType:(BBSActionType)sourceActionType
                         sourceBriefText:(NSString *)sourceBriefText

{
    PBBBSAction_Builder *builder = [[PBBBSAction_Builder alloc] init];
    [builder setActionId:actionId];
    [builder setType:type];
    [builder setDeviceType:deviceType];
    [builder setCreateDate:[createDate timeIntervalSince1970]];
    [builder setReplyCount:replyCount];
    PBBBSUser *createUser = [self buildPBBBSUserWithUserId:userId
                                                  nickName:nickName
                                                    gender:gender
                                                    avatar:avatar];
    [builder setCreateUser:createUser];
    PBBBSContent *content = [self buildPBBBSContentWithType:contentType
                                                       text:text
                                                   imageUrl:imageUrl
                                              thumbImageUrl:thumbImageUrl
                                               drawImageUrl:drawImageUrl
                                          drawImageThumbUrl:drawImageThumbUrl];
    [builder setContent:content];
    PBBBSActionSource *source = [self buildActionSourceWithPostId:sourcePostId
                                                          postUid:sourcePostUid
                                                         actionId:sourceActionId
                                                        actionUid:sourceActionUid sourceActionNickName:sourceActionNickName
                                                       actionType:sourceActionType
                                                        briefText:sourceBriefText];
    [builder setSource:source];

    PBBBSAction *action = [builder build];
    [builder release];
    return action;
}

//#pragma mark - change data with remote.
#pragma mark - bbs board methods

- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        CommonNetworkOutput *output = [BBSNetwork getBBSBoardList:TRAFFIC_SERVER_URL
                                                            appId:appId
                                                           userId:userId
                                                       deviceType:1];
        NSInteger resultCode = [output resultCode];
        NSArray *list = nil;
        @try {
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                list = [response bbsBoardList];
                [[BBSManager defaultManager] setBoardList:list];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
            list = nil;
        }
        @finally {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSBoardList:resultCode:)]) {
                [delegate didGetBBSBoardList:list resultCode:resultCode];
            }
        });
    });
}




#pragma mark - bbs post methods

- (void)createPostWithBoardId:(NSString *)boardId
                         text:(NSString *)text
                        image:(UIImage *)image
               drawActionList:(NSArray *)drawActionList
                    drawImage:(UIImage *)drawImage
                        bonus:(NSInteger)bonus
                     delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        NSString *nText = text;
        PBBBSPost *post = nil;
        
        BBSPostContentType type = ContentTypeText;
        
        NSData *drawData = nil;
        if (image) {
            type = ContentTypeImage;
        }else if (drawImage) {
            type = ContentTypeDraw;
            PBBBSDraw *bbsDraw = [self buildBBSDraw:drawActionList];
            drawData = [bbsDraw data];
        }
        
        NSInteger resultCode = [self checkFrequent];
        if (resultCode == ERROR_SUCCESS){
            resultCode = [self checkWithText:text contentType:type];
        }
        if (resultCode == ERROR_SUCCESS) {
            if ([text length] == 0) {
                nText = [self defaultTextForContentType:type];
            }
            NSInteger deviceType = [DeviceDetection deviceType];
            NSString *appId = [ConfigManager appId];
            
            NSString *userId = [[UserManager defaultManager] userId];
            NSString *nickName = [[UserManager defaultManager] nickName];
            NSString *gender = [[UserManager defaultManager] gender];
            NSString *avatar = [[UserManager defaultManager] avatarURL];
            
            //        DrawDataService de
            //        BBSNetwork
            CommonNetworkOutput *output = [BBSNetwork createPost:TRAFFIC_SERVER_URL
                                                           appId:appId
                                                      deviceType:deviceType
                                                          userId:userId
                                                        nickName:nickName
                                                          gender:gender
                                                          avatar:avatar
                                                         boradId:boardId
                                                     contentType:type
                                                            text:nText
                                                           image:[image data]
                                                        drawData:drawData
                                                       drawImage:[drawImage data]
                                                           bonus:bonus];
            

            resultCode = output.resultCode;
            
            if (resultCode == ERROR_SUCCESS) {
                NSString *postId = [output.jsonDataDict objectForKey:PARA_POSTID];
                NSString *imageURL = [output.jsonDataDict objectForKey:PARA_IMAGE];
                NSString *thumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
                NSString *drawImageURL = [output.jsonDataDict objectForKey:PARA_DRAW_IMAGE];
                NSString *drawThumbURL = [output.jsonDataDict objectForKey:PARA_DRAW_THUMB];
                post = [self buildPBBBSPostWithPostId:postId
                                                appId:appId
                                           deviceType:deviceType
                                               userId:userId
                                             nickName:nickName
                                               gender:gender
                                               avatar:avatar
                                              boradId:boardId
                                          contentType:type
                                                 text:nText
                                             imageUrl:imageURL
                                        thumbImageUrl:thumbURL
                                         drawImageUrl:drawImageURL
                                    drawImageThumbUrl:drawThumbURL
                                                bonus:bonus];
                [[BBSManager defaultManager] updateLastCreationDate];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                [delegate didCreatePost:post resultCode:resultCode];
            }
        });
    });
}


- (PBBBSUser *)myself
{
    PBBBSUser_Builder *builder = [[PBBBSUser_Builder alloc] init];
    NSString *userId = [[UserManager defaultManager] userId];
    NSString *nickName = [[UserManager defaultManager] nickName];
    NSString *gender = [[UserManager defaultManager] gender];
    NSString *avatar = [[UserManager defaultManager] avatarURL];
    [builder setUserId:userId];
    [builder setNickName:nickName];
    [builder setGender:([gender isEqualToString:@"m"])];
    [builder setAvatar:avatar];
    PBBBSUser *user = [builder build];
    [builder release];
    return user;
}

- (void)getBBSPostListWithBoardId:(NSString *)boardId
                        targetUid:(NSString *)targetUid
                        rangeType:(RangeType)rangeType
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<BBSServiceDelegate>)delegate;
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getPostList:TRAFFIC_SERVER_URL
                                                        appId:appId
                                                   deviceType:deviceType
                                                       userId:userId
                                                    targetUid:targetUid
                                                      boardId:boardId
                                                    rangeType:rangeType
                                                       offset:offset
                                                        limit:limit];
        
        NSInteger resultCode = [output resultCode];
        NSArray *list = nil;
        @try {
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                list = [response bbsPostList];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
            list = nil;
        }
        @finally {

        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate) {
                if (boardId != nil && [delegate respondsToSelector:@selector(didGetBBSBoard:postList:rangeType:resultCode:)]) {
                    
                    [delegate didGetBBSBoard:boardId postList:list
                                   rangeType:rangeType
                                  resultCode:resultCode];
                    
                }else if(userId != nil && [delegate respondsToSelector:@selector(didGetUser:postList:resultCode:)]){
                    
                    [delegate didGetUser:userId postList:list
                              resultCode:resultCode];
                    
                }
            }
        });
    });
}


#define BRIEF_TEXT_LENGTH 70

#pragma mark - bbs action methods

- (void)createActionWithPostId:(NSString *)postId
                       PostUid:(NSString *)postUid
                      postText:(NSString *)postText
                  sourceAction:(PBBBSAction *)sourceAction
                    actionType:(BBSActionType)actionType
                          text:(NSString *)text
                         image:(UIImage *)image
                drawActionList:(NSArray *)drawActionList
                     drawImage:(UIImage *)drawImage
                      delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        
        NSString *nText = text;
        NSInteger resultCode = ERROR_SUCCESS;
        PBBBSAction *action = nil;
        
        
        
        BBSPostContentType contentType = ContentTypeNo;
        
        NSData *drawData = nil;
        
        if (image) {
            contentType = ContentTypeImage;
        }else if (drawImage) {
            contentType = ContentTypeDraw;
            PBBBSDraw *bbsDraw = [self buildBBSDraw:drawActionList];
            drawData = [bbsDraw data];
        }else if([text length] != 0){
            contentType = ContentTypeText;
        }
        resultCode = [self checkFrequent];
        if (resultCode == ERROR_SUCCESS && actionType == ActionTypeComment) {
            resultCode = [self checkWithText:text contentType:contentType];
        }
        if (resultCode == ERROR_SUCCESS) {
            
            if ([text length] == 0) {
                nText = [self defaultTextForContentType:contentType];
            }
            NSInteger deviceType = [DeviceDetection deviceType];
            NSString *appId = [ConfigManager appId];
            
            NSString *userId = [[UserManager defaultManager] userId];
            NSString *nickName = [[UserManager defaultManager] nickName];
            NSString *gender = [[UserManager defaultManager] gender];
            NSString *avatar = [[UserManager defaultManager] avatarURL];
            
            NSString *briefText = nil;
            if (sourceAction == nil) {
                briefText = postText;
            }else{
                briefText = sourceAction.content.text;
            }
            if ([briefText length] > BRIEF_TEXT_LENGTH) {
                briefText = [briefText substringToIndex:BRIEF_TEXT_LENGTH];
            }
            CommonNetworkOutput *output = [BBSNetwork createAction:TRAFFIC_SERVER_URL
                                                             appId:appId
                                                        deviceType:deviceType
                                                            userId:userId
                                                          nickName:nickName
                                                            gender:gender
                                                            avatar:avatar
                                           //source
                                                      sourcePostId:postId
                                                     sourcePostUid:postUid
                                                     sourceAtionId:sourceAction.actionId
                                                   sourceActionUid:sourceAction.createUser.userId
                                              sourceActionNickName:sourceAction.createUser.nickName
                                                  sourceActionType:sourceAction.type
                                                         briefText:briefText
                                           //content
                                                       contentType:contentType
                                                        actionType:actionType
                                                              text:nText
                                                             image:[image data]
                                                          drawData:drawData
                                                         drawImage:[drawImage data]];
            resultCode = [output resultCode];
            if (resultCode == ERROR_SUCCESS) {
                NSString *actionId = [output.jsonDataDict objectForKey:PARA_ACTIONID];
                NSString *imageURL = [output.jsonDataDict objectForKey:PARA_IMAGE];
                NSString *thumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
                NSString *drawImageURL = [output.jsonDataDict objectForKey:PARA_DRAW_IMAGE];
                NSString *drawThumbURL = [output.jsonDataDict objectForKey:PARA_DRAW_THUMB];
                
                action = [self buildActionWithActionId:actionId
                                                  type:actionType
                                                 appId:appId
                                            deviceType:deviceType
                                                userId:userId
                                              nickName:nickName
                                                gender:gender
                                                avatar:avatar
                                            createDate:[NSDate date]
                                            replyCount:0
                                           contentType:contentType
                                                  text:nText
                                              imageUrl:imageURL
                                         thumbImageUrl:thumbURL
                                          drawImageUrl:drawImageURL
                                     drawImageThumbUrl:drawThumbURL
                                          sourcePostId:postId
                                         sourcePostUid:postUid
                                        sourceActionId:sourceAction.actionId
                                       sourceActionUid:sourceAction.createUser.userId
                                  sourceActionNickName:sourceAction.createUser.nickName
                                      sourceActionType:sourceAction.type
                                       sourceBriefText:briefText];
                [[BBSManager defaultManager] updateLastCreationDate];
            }
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreateAction:atPost:replyAction:resultCode:)]) {
                [delegate didCreateAction:action atPost:postId
                              replyAction:sourceAction
                               resultCode:resultCode];
            }
        });
    });

}

//- (void)createActionWithPost:(PBBBSPost *)sourcePost
//                sourceAction:(PBBBSAction *)sourceAction
//                  actionType:(BBSActionType)actionType
//                        text:(NSString *)text
//                       image:(UIImage *)image
//              drawActionList:(NSArray *)drawActionList
//                   drawImage:(UIImage *)drawImage
//                    delegate:(id<BBSServiceDelegate>)delegate
//{
//    NSString *postId = sourcePost.postId;
//    NSString *postUid = sourcePost.createUser.userId;
//    NSString *postText = sourcePost.content.text;
//    
//    [self createActionWithPostId:postId
//                         PostUid:postUid
//                        postText:postText
//                    sourceAction:sourceAction
//                      actionType:actionType
//                            text:text
//                           image:image
//                  drawActionList:drawActionList
//                       drawImage:drawImage
//                        delegate:delegate];
//}

- (void)getBBSActionListWithPostId:(NSString *)postId
                        actionType:(BBSActionType)actionType
                            offset:(NSInteger)offset
                             limit:(NSInteger)limit
                          delegate:(id<BBSServiceDelegate>)delegate;
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getActionList:TRAFFIC_SERVER_URL
                                                          appId:appId
                                                     deviceType:deviceType
                                                         userId:userId
                                                      targetUid:nil
                                                         postId:postId
                                                     actionType:actionType
                                                         offset:offset
                                                          limit:limit];
        
        NSInteger resultCode = [output resultCode];
        NSArray *list = nil;
        @try {
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                list = [response bbsActionList];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
            list = nil;
        }
        @finally {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetActionList:belowPost:actionType:resultCode:)]) {
                [delegate didGetActionList:list belowPost:postId actionType:actionType resultCode:resultCode];
            };
        });
    });
}
- (void)getBBSActionListWithTargetUid:(NSString *)targetUid
                               offset:(NSInteger)offset
                                limit:(NSInteger)limit
                             delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getActionList:TRAFFIC_SERVER_URL
                                                          appId:appId
                                                     deviceType:deviceType
                                                         userId:userId
                                                      targetUid:targetUid
                                                         postId:nil
                                                     actionType:ActionTypeNO
                                                         offset:offset
                                                          limit:limit];
        
        NSInteger resultCode = [output resultCode];
        NSArray *list = nil;
        @try {
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                list = [response bbsActionList];
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
            list = nil;
        }
        @finally {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetActionList:targetUid:resultCode:)]) {
                [delegate didGetActionList:list targetUid:targetUid resultCode:resultCode];
            };
        });
    });
}

- (void)payRewardWithPost:(PBBBSPost *)post
                   action:(PBBBSAction *)action
                 delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        PBBBSUser *aUser = action.createUser;
        
        CommonNetworkOutput *output = [BBSNetwork payReward:TRAFFIC_SERVER_URL
                                                     userId:userId
                                                      appId:appId
                                                 deviceType:deviceType
                                                     postId:post.postId
                                                   actionId:action.actionId
                                                  actionUid:aUser.userId
                                                 actionNick:aUser.nickName
                                               actionGender:aUser.genderString
                                               actionAvatar:aUser.avatar];
        
        NSInteger resultCode = [output resultCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didPayBBSRewardWithPost:action:resultCode:)]) {
                [delegate didPayBBSRewardWithPost:post
                                           action:action
                                       resultCode:resultCode];
            }
        });
    });

}


#pragma common methods

- (void)getBBSDrawDataWithPostId:(NSString *)postId
                        actionId:(NSString *)actionId
                        delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        
        BOOL fromRemote = NO;
        NSInteger resultCode = ERROR_SUCCESS;
        NSMutableArray *drawActionList = nil;
        
        //load from local data
        BBSManager *_bbsManager = [BBSManager defaultManager];
        NSString *key = postId;
        if ([key length] == 0) {
            key = actionId;
        }
        PBBBSDraw *draw = [_bbsManager loadBBSDrawDataFromCacheWithKey:key];
        
        //load from remote
        if (draw == nil) {
            
            PPDebug(@"<getBBSDrawDataWithPostId> load data from remote service");
            
            fromRemote = YES;
            CommonNetworkOutput *output = [BBSNetwork getBBSDrawData:TRAFFIC_SERVER_URL
                                                               appId:appId
                                                          deviceType:[DeviceDetection deviceType]
                                                              userId:userId
                                                              postId:postId
                                                            actionId:actionId];
            resultCode = [output resultCode];
            @try {
                if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                    DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                    resultCode = [response resultCode];
                    draw = [response bbsDrawData];
                    [_bbsManager cacheBBSDrawData:draw forKey:key];
                }
            }
            @catch (NSException *exception) {
                PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
                drawActionList = nil;
            }
            @finally {
                
            }
        }
        //parse draw data
        NSArray *list = [draw drawActionListList];
        drawActionList = [DrawManager parseFromPBDrawActionList:list];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSDrawActionList:postId:actionId:fromRemote:resultCode:)]) {
                [delegate didGetBBSDrawActionList:drawActionList
                                           postId:postId
                                         actionId:actionId
                                       fromRemote:fromRemote
                                       resultCode:resultCode];
            }
        });
    });
}

- (void)getBBSPostWithPostId:(NSString *)postId
                    delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork getBBSPost:TRAFFIC_SERVER_URL
                                                       appId:appId
                                                  deviceType:deviceType
                                                      userId:userId
                                                      postId:postId];
        
        NSInteger resultCode = [output resultCode];
        
        PBBBSPost *post = nil;
        @try {
            if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                resultCode = [response resultCode];
                NSArray *list = [response bbsPostList];
                if ([list count] != 0) {
                    post = [response bbsPostAtIndex:0];
                }
            }
        }
        @catch (NSException *exception) {
            PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
            post = nil;
        }
        @finally {
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSPost:postId:resultCode:)]) {
                [delegate didGetBBSPost:post postId:postId resultCode:resultCode];
            }
        });
    });
}

- (void)deletePostWithPostId:(NSString *)postId
                    delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork deleteBBSPost:TRAFFIC_SERVER_URL
                                                          appId:appId
                                                     deviceType:deviceType
                                                         userId:userId
                                                         postId:postId];
        NSInteger resultCode = [output resultCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didDeleteBBSPost:resultCode:)]) {
                [delegate didDeleteBBSPost:postId resultCode:resultCode];
            }
        });
    });
}

- (void)deleteActionWithActionId:(NSString *)actionId
                        delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork deleteBBSAction:TRAFFIC_SERVER_URL
                                                            appId:appId
                                                       deviceType:deviceType
                                                           userId:userId
                                                         actionId:actionId];
        NSInteger resultCode = [output resultCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didDeleteBBSAction:resultCode:)]) {
                [delegate didDeleteBBSAction:actionId resultCode:resultCode];
            }
        });
    });
    
}

@end
