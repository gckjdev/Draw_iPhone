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

BBSService *_staticBBSService;

@implementation BBSService

+ (id)defaultService
{
    if (_staticBBSService == nil) {
        _staticBBSService = [[BBSService alloc] init];
    }
    return _staticBBSService;
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
                                        actionType:(BBSActionType)actionType
                                         briefText:(NSString *)briefText
{
    PBBBSActionSource_Builder *builder = [[PBBBSActionSource_Builder alloc] init];
    builder.postId = postId;
    [builder setPostUid:postUid];
    [builder setActionId:actionId];
    [builder setActionUid:actionUid];
    [builder setActionType:actionType];
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
                                                        actionUid:sourceActionUid
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
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *nickName = [[UserManager defaultManager] nickName];
        NSString *gender = [[UserManager defaultManager] gender];
        NSString *avatar = [[UserManager defaultManager] avatarURL];
        
        BBSPostContentType type = ContentTypeText;
        
        NSData *drawData = nil;
        
        if (image) {
            type = ContentTypeImage;
        }else if (drawImage) {
            type = ContentTypeDraw;
            PBBBSDraw *bbsDraw = [self buildBBSDraw:drawActionList];
            drawData = [bbsDraw data];
        }
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
                                                        text:text
                                                       image:[image data]
                                                    drawData:drawData
                                                   drawImage:[drawImage data]
                                                       bonus:bonus];
        
        PBBBSPost *post = nil;
        if (output.resultCode == ERROR_SUCCESS) {
            NSString *postId = [output.jsonDataDict objectForKey:PARA_POSTID];
            NSString *imageURL = [output.jsonDataDict objectForKey:PARA_IMAGE];
            NSString *thumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
            NSString *drawImageURL = [output.jsonDataDict objectForKey:PARA_DRAW_IMAGE];
            NSString *drawThumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
            post = [self buildPBBBSPostWithPostId:postId
                                                       appId:appId
                                                  deviceType:deviceType
                                                      userId:userId
                                                    nickName:nickName
                                                      gender:gender
                                                      avatar:avatar
                                                     boradId:boardId
                                                 contentType:type
                                                        text:text
                                                    imageUrl:imageURL
                                               thumbImageUrl:thumbURL
                                                drawImageUrl:drawImageURL
                                           drawImageThumbUrl:drawThumbURL];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                [delegate didCreatePost:post resultCode:output.resultCode];
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
- (void)createActionWithPost:(PBBBSPost *)sourcePost
                sourceAction:(PBBBSAction *)sourceAction
                  actionType:(BBSActionType)actionType
                        text:(NSString *)text
                       image:(UIImage *)image
              drawActionList:(NSArray *)drawActionList
                   drawImage:(UIImage *)drawImage
                    delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [ConfigManager appId];
        
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *nickName = [[UserManager defaultManager] nickName];
        NSString *gender = [[UserManager defaultManager] gender];
        NSString *avatar = [[UserManager defaultManager] avatarURL];
        
        BBSPostContentType contentType = ContentTypeText;
        
        NSData *drawData = nil;
        
        if (image) {
            contentType = ContentTypeImage;
        }else if (drawImage) {
            contentType = ContentTypeDraw;
            PBBBSDraw *bbsDraw = [self buildBBSDraw:drawActionList];
            drawData = [bbsDraw data];
        }
        
        NSString *briefText = nil;
        if (sourceAction == nil) {
            briefText = sourcePost.content.text;
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
                                                  sourcePostId:sourcePost.postId
                                                 sourcePostUid:sourcePost.createUser.userId
                                                 sourceAtionId:sourceAction.actionId
                                               sourceActionUid:sourceAction.createUser.userId
                                              sourceActionType:sourceAction.type
                                                     briefText:briefText
                                       //content
                                                   contentType:contentType
                                                    actionType:actionType
                                                          text:text
                                                         image:[image data]
                                                      drawData:drawData
                                                     drawImage:[drawImage data]];
        NSInteger resultCode = [output resultCode];
        PBBBSAction *action = nil;
        if (resultCode == ERROR_SUCCESS) {
            NSString *actionId = [output.jsonDataDict objectForKey:PARA_ACTIONID];
            NSString *imageURL = [output.jsonDataDict objectForKey:PARA_IMAGE];
            NSString *thumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
            NSString *drawImageURL = [output.jsonDataDict objectForKey:PARA_DRAW_IMAGE];
            NSString *drawThumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
            
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
                                              text:text
                                          imageUrl:imageURL
                                     thumbImageUrl:thumbURL
                                      drawImageUrl:drawImageURL
                                 drawImageThumbUrl:drawThumbURL
                                      sourcePostId:sourcePost.postId
                                     sourcePostUid:sourcePost.createUser.userId
                                    sourceActionId:sourceAction.actionId
                                   sourceActionUid:sourceAction.createUser.userId
                                  sourceActionType:sourceAction.type
                                   sourceBriefText:briefText];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreateAction:atPost:replyAction:resultCode:)]) {
                [delegate didCreateAction:action atPost:sourcePost
                              replyAction:sourceAction
                               resultCode:resultCode];
            }
        });
    });

}




@end
