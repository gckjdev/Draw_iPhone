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
#import "BBSPermissionManager.h"
#import "CanvasRect.h"

BBSService *_staticBBSService;

@interface BBSService()

@property(nonatomic, retain)NSString *lastPostText;

@end

@implementation BBSService

- (void)dealloc
{
    PPRelease(_lastPostText);
    [super dealloc];
}

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
    BBSManager *_bbsManager = [BBSManager defaultManager];
    if ([_bbsManager isCreationFrequent]) {
        PPDebug(@"<checkFrequent> to frequent!!!");
        return ERROR_BBS_TEXT_TOO_FREQUENT;
    }else{
        return ERROR_SUCCESS;
    }
}


- (NSInteger)checkContentRepeated:(NSString *)text
{
    if ([text isEqualToString:self.lastPostText]) {
        PPDebug(@"<checkContentRepeat> Content Repeat!!!");
        return ERROR_BBS_TEXT_REPEAT;
    }else{
        return ERROR_SUCCESS;
    }
}


- (NSInteger)checkCanSupportPost:(NSString *)postId
{
    BBSManager *_bbsManager = [BBSManager defaultManager];
    if (![_bbsManager canSupportPost:postId]) {
        PPDebug(@"<checkCanSupportPost> to frequent!!!");
        return ERROR_BBS_POST_SUPPORT_TIMES_LIMIT;
    }else{
        return ERROR_SUCCESS;
    }
}

- (NSInteger)checkWithText:(NSString *)text
               contentType:(BBSPostContentType)type
                    isPost:(BOOL)isPost
{
    BBSManager *_bbsManager = [BBSManager defaultManager];
    if (type == ContentTypeText) {
         if ([text length] < [_bbsManager textMinLength]) {
             PPDebug(@"<checkWithText> text(%@) to short!!!",text);
             return ERROR_BBS_TEXT_TOO_SHORT;
         } else if (isPost && [text length] > [_bbsManager postTextMaxLength]){
             //post text
             PPDebug(@"<checkWithText> post text(%@) to long!!!",text);
             return ERROR_BBS_TEXT_TOO_LONG;
         } else if (!isPost && [text length] > [_bbsManager commentTextMaxLength]){
             //post text
             PPDebug(@"<checkWithText> comment text(%@) to long!!!",text);
             return ERROR_BBS_TEXT_TOO_LONG;
         }
    }
    return ERROR_SUCCESS;
}


- (NSString *)defaultTextForContentType:(BBSPostContentType)type
{
    if (ContentTypeDraw == type) {
        return NSLS(@"kBBSDraw");
    }
    if (ContentTypeImage == type) {
        return NSLS(@"kBBSImage");
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

//+ (PBBBSDraw *)buildBBSDraw:(NSArray *)drawActionList canvasSize:(CGSize)size;
//{
//    PBBBSDraw *bbsDraw = nil;
//    NSMutableArray *pbDrawActionList = [NSMutableArray arrayWithCapacity:drawActionList.count];
//    for (DrawAction *action in drawActionList) {
//        PBDrawAction * pbAction = [action toPBDrawAction];
//        [pbDrawActionList addObject:pbAction];
//    }
//    if ([pbDrawActionList count] != 0) {
//        PBBBSDraw_Builder *builder = [[PBBBSDraw_Builder alloc] init];
//        [builder addAllDrawActionList:pbDrawActionList];
//        [builder setVersion:[ConfigManager currentDrawDataVersion]];
//        [builder setCanvasSize:CGSizeToPBSize(size)];
//        bbsDraw = [builder build];
//        [builder release];
//    }
//    return bbsDraw;
//}



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
        NSString *gameId = [ConfigManager gameId];
        
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput *output = [BBSNetwork getBBSBoardList:TRAFFIC_SERVER_URL
                                                            appId:appId
                                                           userId:userId
                                                       deviceType:1
                                                           gameId:gameId
                                                         language:lang];
        dispatch_async(dispatch_get_main_queue(), ^{
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
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSBoardList:resultCode:)]) {
                [delegate didGetBBSBoardList:list resultCode:resultCode];
            }
        });
    });
}



#define CREATE_POST_QUEUE @"CREATE_POST_QUEUE"


#pragma mark - bbs post methods

- (void)createPostWithBoardId:(NSString *)boardId
                         text:(NSString *)text
                        image:(UIImage *)image
               drawActionList:(NSArray *)drawActionList
                    drawImage:(UIImage *)drawImage
                        bonus:(NSInteger)bonus
                     delegate:(id<BBSServiceDelegate>)delegate
                   canvasSize:(CGSize)size
{

        BBSPostContentType type = ContentTypeText;
    
        NSData *drawData = nil;
        if (image) {
            type = ContentTypeImage;
        }else if (drawImage) {
            type = ContentTypeDraw;
//            PBBBSDraw *bbsDraw = [BBSService buildBBSDraw:drawActionList canvasSize:size];
//            drawData = [bbsDraw data];
            drawData = [DrawAction buildBBSDrawData:drawActionList canvasSize:size];
        }
        
        NSInteger resultCode = [self checkFrequent];
        if (resultCode == ERROR_SUCCESS){
            resultCode = [self checkWithText:text contentType:type isPost:YES];
        }

        NSString *nText = text;
        if ([text length] == 0) {
            nText = [self defaultTextForContentType:type];
        }

        if (resultCode == ERROR_SUCCESS) {
            resultCode = [self checkContentRepeated:nText];
        }
    
        if (resultCode != ERROR_SUCCESS) {
            if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                [delegate didCreatePost:nil resultCode:resultCode];
            }
            return;
        }

        NSOperationQueue *queue = [self getOperationQueue:CREATE_POST_QUEUE];
        [queue cancelAllOperations];
    
    
        [queue addOperationWithBlock: ^{
            NSInteger deviceType = [DeviceDetection deviceType];
            NSString *appId = [ConfigManager appId];
            
            NSString *userId = [[UserManager defaultManager] userId];
            NSString *nickName = [[UserManager defaultManager] nickName];
            NSString *gender = [[UserManager defaultManager] gender];
            NSString *avatar = [[UserManager defaultManager] avatarURL];
            
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
            
            NSInteger resultCode = output.resultCode;
            PBBBSPost *post = nil;
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
                self.lastPostText = nText;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                    [delegate didCreatePost:post resultCode:resultCode];
                }

            });
        }];
}

#pragma mark - bbs privilege methods
- (void)changeBBSUser:(NSString *)targetUid
                 role:(BBSUserRole)role
              boardId:(NSString *)boardId
           expireDate:(NSDate *)expireDate
                 info:(NSDictionary *)info //for the futrue
             delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{

        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        
        CommonNetworkOutput *output = [BBSNetwork changeBBSUserRole:TRAFFIC_SERVER_URL
                                                              appId:appId
                                                         deviceType:deviceType
                                                             userId:userId
                                                          targetUid:targetUid
                                                            boardId:boardId
                                                           roleType:role
                                                         expireDate:expireDate
                                                               info:info];
        NSInteger resultCode = [output resultCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didChangeUser:role:boardId:resultCode:)]) {
                [delegate didChangeUser:targetUid role:role boardId:boardId resultCode:resultCode];
            }
        });
    });

}

- (void)getBBSPrivilegeList
{
    if ([[UserManager defaultManager] hasUser] == NO){
        return;
    }
    
    NSString *userId = [[UserManager defaultManager] userId];
    NSString *appId = [ConfigManager appId];
    NSInteger deviceType = [DeviceDetection deviceType];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput *output = [BBSNetwork getBBSPrivilegeList:TRAFFIC_SERVER_URL
                                                                appId:appId
                                                           deviceType:deviceType
                                                               userId:userId];
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS && [output.responseData length] > 0)
        {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            if (resultCode == ERROR_SUCCESS) {
                NSArray *list = [response bbsPrivilegeListList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[BBSPermissionManager defaultManager] updatePrivilegeList:list];
                });
            }

        }
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
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
                    canvasSize:(CGSize)size
{
        NSInteger resultCode = ERROR_SUCCESS;
        BBSPostContentType contentType = ContentTypeNo;
        NSData *drawData = nil;
        
        if (actionType == ActionTypeSupport) {
            resultCode = [self checkCanSupportPost:postId];
        }
        if (resultCode == ERROR_SUCCESS) {
            resultCode = [self checkFrequent];
        }
        if(resultCode == ERROR_SUCCESS){
            if (image) {
                contentType = ContentTypeImage;
            }else if (drawImage) {
                contentType = ContentTypeDraw;
                drawData = [DrawAction buildBBSDrawData:drawActionList canvasSize:size];
//                PBBBSDraw *bbsDraw = [BBSService buildBBSDraw:drawActionList canvasSize:size];
//                drawData = [bbsDraw data];
            }else{
                contentType = ContentTypeText;
            }
        }
        
        if (resultCode == ERROR_SUCCESS && actionType == ActionTypeComment) {
            resultCode = [self checkWithText:text
                                 contentType:contentType
                                      isPost:NO];
        }
    
    
        NSString *nText = text;
        if ([text length] == 0) {
            nText = [self defaultTextForContentType:contentType];
        }
        
        if (resultCode == ERROR_SUCCESS) {
            resultCode = [self checkContentRepeated:nText];
        }

    
        if (resultCode != ERROR_SUCCESS) {
            if (delegate && [delegate respondsToSelector:@selector(didCreateAction:atPost:replyAction:resultCode:)]) {
                    [delegate didCreateAction:nil
                                       atPost:postId
                                  replyAction:sourceAction
                                   resultCode:resultCode];
                }
            return;
        }
    
        if (actionType == ActionTypeSupport) {
            [[BBSManager defaultManager] increasePostSupportTimes:postId];
        }
    
        NSOperationQueue *queue = [self getOperationQueue:CREATE_POST_QUEUE];
        [queue cancelAllOperations];

        [queue addOperationWithBlock: ^{
//            NSString *nText = text;
//            
//            if ([text length] == 0) {
//                nText = [self defaultTextForContentType:contentType];
//            }
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

            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                PBBBSAction *buildAction = nil;
                NSInteger resultCode = [output resultCode];
                if (resultCode != ERROR_SUCCESS) {
                    if (actionType == ActionTypeSupport) {
                        [[BBSManager defaultManager] decreasePostSupportTimes:postId];
                    }
                }else if (resultCode == ERROR_SUCCESS) {
                    
                    self.lastPostText = nText;
                    
                    NSString *actionId = [output.jsonDataDict objectForKey:PARA_ACTIONID];
                    NSString *imageURL = [output.jsonDataDict objectForKey:PARA_IMAGE];
                    NSString *thumbURL = [output.jsonDataDict objectForKey:PARA_THUMB_IMAGE];
                    NSString *drawImageURL = [output.jsonDataDict objectForKey:PARA_DRAW_IMAGE];
                    NSString *drawThumbURL = [output.jsonDataDict objectForKey:PARA_DRAW_THUMB];
                    
                    buildAction = [self buildActionWithActionId:actionId
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
                if (delegate && [delegate respondsToSelector:@selector(didCreateAction:atPost:replyAction:resultCode:)]) {
                    [delegate didCreateAction:buildAction atPost:postId
                                  replyAction:sourceAction
                                   resultCode:resultCode];
                }
            });
        }];
    
}


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
    
        //load from local data
        BBSManager *_bbsManager = [BBSManager defaultManager];
        NSString *key = postId;
        if ([key length] == 0) {
            key = actionId;
        }
        PBBBSDraw *draw = [_bbsManager loadBBSDrawDataFromCacheWithKey:key];
    
        if (draw != nil) {
            PPDebug(@"<getBBSDrawDataWithPostId> load data from local service");
//            NSArray *list = [draw drawActionListList];
            NSMutableArray *drawActionList = [DrawAction drawActionListFromPBBBSDraw:draw];
//            NSMutableArray *drawActionList = [DrawManager parseFromPBDrawActionList:list];
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSDrawActionList:drawDataVersion:canvasSize:postId:actionId:fromRemote:resultCode:)]) {
                
                CGSize size = [draw hasCanvasSize] ? (CGSizeFromPBSize(draw.canvasSize)) : [CanvasRect deprecatedIPhoneRect].size;
                
                [delegate didGetBBSDrawActionList:drawActionList
                                  drawDataVersion:draw.version
                                       canvasSize:size 
                                           postId:postId
                                         actionId:actionId
                                       fromRemote:NO
                                       resultCode:ERROR_SUCCESS];
            }
            return;
        }
    

        dispatch_async(workingQueue, ^{
            PPDebug(@"<getBBSDrawDataWithPostId> load data from remote service");
            NSString *userId = [[UserManager defaultManager] userId];
            NSString *appId = [ConfigManager appId];
        
            CommonNetworkOutput *output = [BBSNetwork getBBSDrawData:TRAFFIC_SERVER_URL
                                                               appId:appId
                                                          deviceType:[DeviceDetection deviceType]
                                                              userId:userId
                                                              postId:postId
                                                            actionId:actionId];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger resultCode = [output resultCode];
                NSMutableArray *drawActionList = nil;
                PBBBSDraw *remoteDraw = nil;
                @try {
                    if (output.resultCode == ERROR_SUCCESS && [output.responseData length] > 0) {
                        DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
                        resultCode = [response resultCode];
                        if (resultCode == ERROR_SUCCESS) {
                            remoteDraw = [response bbsDrawData];
                            [_bbsManager cacheBBSDrawData:remoteDraw forKey:key];
                            //
                            
                            drawActionList = [DrawAction drawActionListFromPBBBSDraw:remoteDraw];
//                            NSArray *list = [remoteDraw drawActionListList];
//                            drawActionList = [DrawManager parseFromPBDrawActionList:list];
                            //
                        }
                    }
                }
                @catch (NSException *exception) {
                    PPDebug(@"<getBBSBoardList>exception = %@",[exception debugDescription]);
                }
                @finally {
                    
                }
                if (delegate && [delegate respondsToSelector:@selector(didGetBBSDrawActionList:drawDataVersion:canvasSize:postId:actionId:fromRemote:resultCode:)]) {
                    CGSize size = [remoteDraw hasCanvasSize] ? (CGSizeFromPBSize(remoteDraw.canvasSize)) : [CanvasRect deprecatedIPhoneRect].size;
                    [delegate didGetBBSDrawActionList:drawActionList
                                      drawDataVersion:remoteDraw.version
                                           canvasSize:size 
                                               postId:postId
                                             actionId:actionId
                                           fromRemote:YES
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


- (void)deletePost:(PBBBSPost *)post
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
                                                         postId:post.postId
                                                        boardId:post.boardId];
        NSInteger resultCode = [output resultCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didDeleteBBSPost:resultCode:)]) {
                [delegate didDeleteBBSPost:post resultCode:resultCode];
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

#pragma mark - update post methods

- (void)editPost:(PBBBSPost *)post
         boardId:(NSString *)boardId
          status:(NSInteger)status
            info:(NSDictionary *)info //for the futrue
        delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        PPDebug(@"transfer post from board(%@) to board(%@)",post.boardId, boardId);
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [ConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork editBBSPost:TRAFFIC_SERVER_URL
                                                        appId:appId
                                                   deviceType:deviceType
                                                       userId:userId
                                                       postId:post.postId
                                                      boardId:boardId
                                                       status:status
                                                         info:nil];
        NSInteger resultCode = [output resultCode];
        PBBBSPost *tempPost = nil;
        if (resultCode == ERROR_SUCCESS) {
            PBBBSPost_Builder  *builder = [PBBBSPost builderWithPrototype:post];
            if ([boardId length] != 0) {
                [builder setBoardId:boardId];
            }
            [builder setStatus:status];
            tempPost = [builder build];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didEditPostPost:resultCode:)]) {
                [delegate didEditPostPost:tempPost resultCode:resultCode];
            }
        });
    });
}

@end
