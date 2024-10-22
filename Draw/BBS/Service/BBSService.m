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
#import "PPConfigManager.h"
#import "DrawDataService.h"
#import "UIImageExt.h"

#import "DrawAction.h"
#import "BBSPermissionManager.h"
#import "CanvasRect.h"
#import "UIViewController+CommonHome.h"
#import "TutorialService.h"
#import "BBSPostDetailController.h"

BBSService *_staticBBSService;
BBSService *_staticGroupTopicService;

@interface BBSService()

@property(nonatomic, retain)NSString *lastPostText;
@property(nonatomic, assign)BOOL isGroupTopicService;
@end




@implementation BBSService

- (NSString *)hostURL
{
    NSString *host = [PPConfigManager getBBSServerURL];
    if (_isGroupTopicService) {
        host = [PPConfigManager getGroupServerURL];
        return [NSString stringWithFormat:@"%@%@=%d",host,PARA_TOPIC_MODE,CONST_GROUP_MODE];
    }
    return host;
}

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

+ (id)groupTopicService
{
    if (_staticGroupTopicService == nil) {
        _staticGroupTopicService = [[BBSService alloc] init];
        _staticGroupTopicService.isGroupTopicService = YES;
    }
    return _staticGroupTopicService;
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
    if (ContentTypeDrawOpus == type) {
        return NSLS(@"kBBSDrawOpus");
    }
    if (ContentTypeSingOpus == type) {
        return NSLS(@"kBBSSingOpus");
    }
    return nil;
}

#pragma mark - pb data builder

- (PBBBSUser *)buildPBBBSUserWithUserId:(NSString*)userId
                               nickName:(NSString*)nickName
                                 gender:(NSString*)gender
                                 avatar:(NSString*)avatar
{
    PBBBSUserBuilder *builder = [[PBBBSUserBuilder alloc] init];
    [builder setUserId:userId];
    [builder setNickName:nickName];
    [builder setGender:([gender isEqualToString:@"m"] ? YES : NO)];
    [builder setAvatar:avatar];
    PBBBSUser *user = [builder build];
    [builder release];
    return user;
}


- (PBBBSContent *)buildPBBBSContentWithType:(NSInteger)type
                                       text:(NSString *)text
                                   imageUrl:(NSString *)imageUrl
                              thumbImageUrl:(NSString *)thumbImageUrl
                               drawImageUrl:(NSString *)drawImageUrl
                          drawImageThumbUrl:(NSString *)drawImageThumbUrl
                                     opusId:(NSString *)opusId
                               opusCategory:(int)opusCategory

{
    PBBBSContentBuilder *builder = [[PBBBSContentBuilder alloc] init];
    [builder setType:type];
    [builder setText:text];
    [builder setImageUrl:imageUrl];
    [builder setThumbImageUrl:thumbImageUrl];
    [builder setDrawImageUrl:drawImageUrl];
    [builder setDrawThumbUrl:drawImageThumbUrl];
    [builder setOpusId:opusId];
    [builder setOpusCategory:opusCategory];
    PBBBSContent *content = [builder build];
    [builder release];
    return content;
}

- (PBBBSReward *)buildPBBBSRewardWithBounus:(NSInteger)bonus
{
    if (bonus <= 0) {
        return nil;
    }
    PBBBSRewardBuilder *builder = [[PBBBSRewardBuilder alloc] init];
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
                                 opusId:(NSString *)opusId
                           opusCategory:(int)opusCategory
                                  bonus:(NSInteger)bonus
{
    PBBBSPostBuilder *builder = [[PBBBSPostBuilder alloc] init];
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
                                          drawImageThumbUrl:drawImageThumbUrl
                                                     opusId:opusId
                                               opusCategory:opusCategory];
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
//        PBBBSDrawBuilder *builder = [[PBBBSDrawBuilder alloc] init];
//        [builder addAllDrawActionList:pbDrawActionList];
//        [builder setVersion:[PPConfigManager currentDrawDataVersion]];
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
    PBBBSActionSourceBuilder *builder = [[PBBBSActionSourceBuilder alloc] init];
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
                                  opusId:(NSString *)opusId
                            opusCategory:(int)opusCategory
                            sourcePostId:(NSString *)sourcePostId
                           sourcePostUid:(NSString *)sourcePostUid
                          sourceActionId:(NSString *)sourceActionId
                         sourceActionUid:(NSString *)sourceActionUid
                    sourceActionNickName:(NSString *)sourceActionNickName
                        sourceActionType:(BBSActionType)sourceActionType
                         sourceBriefText:(NSString *)sourceBriefText

{
    PBBBSActionBuilder *builder = [[PBBBSActionBuilder alloc] init];
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
                                          drawImageThumbUrl:drawImageThumbUrl
                                                     opusId:opusId
                                               opusCategory:opusCategory];
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


/*
 
 db.bbs_board.find({"_id":ObjectId("50bd8c62e4b0e970bbebc747")})
 db.bbs_board.update({"_id":ObjectId("50bd8c62e4b0e970bbebc747")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/s_draw.png"}})
 
 boardId    __NSCFString *    @"53f1658de4b0400953eec7e7"    0x00006000003f36c0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e750e0

 db.bbs_board.find({"_id":ObjectId("53f1658de4b0400953eec7e7")})
 db.bbs_board.update({"_id":ObjectId("53f1658de4b0400953eec7e7")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 
 boardId    __NSCFString *    @"50bd8c62e4b0e970bbebc74a"    0x00006000003f39c0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_announce.png"    0x0000600002e744b0
 db.bbs_board.find({"_id":ObjectId("50bd8c62e4b0e970bbebc74a")})
 db.bbs_board.update({"_id":ObjectId("50bd8c62e4b0e970bbebc74a")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_announce.png"}})

 boardId    __NSCFString *    @"532cf231e4b0f2e3448f2f12"    0x00006000003f3c00
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e74e60
 db.bbs_board.find({"_id":ObjectId("532cf231e4b0f2e3448f2f12")})
 db.bbs_board.update({"_id":ObjectId("532cf231e4b0f2e3448f2f12")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 boardId    __NSCFString *    @"5184884ca1ebdc1c9b49c803"    0x00006000003f0bd0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_student.png"    0x0000600002e75540
 db.bbs_board.find({"_id":ObjectId("5184884ca1ebdc1c9b49c803")})
 db.bbs_board.update({"_id":ObjectId("5184884ca1ebdc1c9b49c803")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_student.png"}})

 boardId    __NSCFString *    @"53294f12e4b0f2e3448f28c5"    0x00006000003f3db0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e74c80
 db.bbs_board.find({"_id":ObjectId("53294f12e4b0f2e3448f28c5")})
 db.bbs_board.update({"_id":ObjectId("53294f12e4b0f2e3448f28c5")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 boardId    __NSCFString *    @"5325a3bae4b0f2e3448f2424"    0x00006000003f6cd0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e753b0
 db.bbs_board.find({"_id":ObjectId("5325a3bae4b0f2e3448f2424")})
 db.bbs_board.update({"_id":ObjectId("5325a3bae4b0f2e3448f2424")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 boardId    __NSCFString *    @"5324773de4b0f2e3448f224d"    0x00006000003f6970
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e75090
 db.bbs_board.find({"_id":ObjectId("5324773de4b0f2e3448f224d")})
 db.bbs_board.update({"_id":ObjectId("5324773de4b0f2e3448f224d")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 boardId    __NSCFString *    @"50f66a804868709cee3eef50"    0x00006000003f79f0
 icon    __NSCFString *    @"http://58.215.160.100:8080/bbs/icon/b_picture.png"    0x0000600002e75220
 db.bbs_board.find({"_id":ObjectId("50f66a804868709cee3eef50")})
 db.bbs_board.update({"_id":ObjectId("50f66a804868709cee3eef50")}, {$set:{"icon":"http://43.247.90.45:8080/bbs/icon/b_picture.png"}})

 
 
 */

//#pragma mark - change data with remote.
#pragma mark - bbs board methods

- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [PPConfigManager appId];                
        NSString *gameId = DRAW_GAME_ID; //[PPConfigManager gameId];  // point to draw game always for sing/draw/etc
        
        LanguageType lang = [[UserManager defaultManager] getLanguageType];
        
        CommonNetworkOutput *output = [BBSNetwork getBBSBoardList:[self hostURL]
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
                    list = [response bbsBoard];
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
                       opusId:(NSString *)opusId
                 opusCategory:(int)opusCategory
                        bonus:(NSInteger)bonus
                     delegate:(id<BBSServiceDelegate>)delegate
                   canvasSize:(CGSize)size
                    isPrivate:(BOOL)isPrivate
{

        BBSPostContentType type = ContentTypeText;
    
        NSData *drawData = nil;
        if ([opusId length] > 0){
            if (opusCategory == PBOpusCategoryTypeSingCategory){
                type = ContentTypeSingOpus;
            }
            else{
                type = ContentTypeDrawOpus;
            }
        }
        else if (image) {
            type = ContentTypeImage;
        }else if (drawImage) {
            type = ContentTypeDraw;
            drawData = [DrawAction buildBBSDrawData:drawActionList canvasSize:size info:nil];
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
            
            [self showErrorUserForbidden:resultCode];
            
            return;
        }

        NSOperationQueue *queue = [self getOperationQueue:CREATE_POST_QUEUE];
        [queue cancelAllOperations];
    
    
        [queue addOperationWithBlock: ^{
            NSInteger deviceType = [DeviceDetection deviceType];
            NSString *appId = [PPConfigManager appId];
            
            NSString *userId = [[UserManager defaultManager] userId];
            NSString *nickName = [[UserManager defaultManager] nickName];
            NSString *gender = [[UserManager defaultManager] gender];
            NSString *avatar = [[UserManager defaultManager] avatarURL];
            
            CommonNetworkOutput *output = [BBSNetwork createPost:[self hostURL]
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
                                                          opusId:opusId
                                                    opusCategory:opusCategory
                                                           bonus:bonus
                                                       isPrivate:isPrivate];
            
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
                                               opusId:opusId
                                         opusCategory:opusCategory
                                                bonus:bonus];
                [[BBSManager defaultManager] updateLastCreationDate];
                self.lastPostText = nText;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                    [delegate didCreatePost:post resultCode:resultCode];
                }
                
                [self showErrorUserForbidden:resultCode];

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
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        
        CommonNetworkOutput *output = [BBSNetwork changeBBSUserRole:[self hostURL]
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
    NSString *appId = [PPConfigManager appId];
    NSInteger deviceType = [DeviceDetection deviceType];
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput *output = [BBSNetwork getBBSPrivilegeList:[self hostURL]
                                                                appId:appId
                                                           deviceType:deviceType
                                                               userId:userId];
        NSInteger resultCode = output.resultCode;
        if (resultCode == ERROR_SUCCESS && [output.responseData length] > 0)
        {
            DataQueryResponse *response = [DataQueryResponse parseFromData:output.responseData];
            resultCode = [response resultCode];
            if (resultCode == ERROR_SUCCESS) {
                NSArray *list = [response bbsPrivilegeList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[BBSPermissionManager defaultManager] updatePrivilegeList:list];
                });
            }

        }
    });
}



- (PBBBSUser *)myself
{
    PBBBSUserBuilder *builder = [[PBBBSUserBuilder alloc] init];
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
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getPostList:[self hostURL]
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
                    list = [response bbsPost];
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


- (void)searchPostListByKeyWord:(NSString *)keyWord
                        inGroup:(NSString *)groupId
                         offset:(NSInteger)offset
                          limit:(NSInteger)limit
                        hanlder:(BBSGetPostResultHandler)handler;
{
    if ([keyWord length] == 0) {
        return;
    }
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];

        NSDictionary *paras = @{PARA_DEVICETYPE : @(deviceType),
                                PARA_APPID : appId,
                                PARA_USERID : userId,
                                PARA_KEYWORD : keyWord,
                                PARA_OFFSET : @(offset),
                                PARA_LIMIT : @(limit),
                                };

        if ([groupId length] != 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setDictionary:paras];
            //the parameter here is right here. by gamy
            [dict setObject:groupId forKey:PARA_BOARDID];
            paras = dict;
        }
        
        GameNetworkOutput *output = [BBSNetwork sendGetRequestWithBaseURL:[self hostURL]
                                       method:METHOD_SEARCH_BBSPOST_LIST
                                   parameters:paras
                                     returnPB:YES
                              returnJSONArray:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger resultCode = [output resultCode];
            NSArray *list = output.pbResponse.bbsPost;
            EXECUTE_BLOCK(handler, resultCode, list, 0);
        });
    });
}

- (void)getPostActionByUser:(NSString *)targetUid
                     postId:(NSString *)postId
                     offset:(NSInteger)offset
                      limit:(NSInteger)limit
                    hanlder:(BBSGetPostResultHandler)handler
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        NSDictionary *paras = @{PARA_DEVICETYPE : @(deviceType),
                                PARA_APPID : appId,
                                PARA_USERID : userId,
                                PARA_POSTID : postId,
                                PARA_TARGETUSERID : targetUid,
                                PARA_OFFSET : @(offset),
                                PARA_LIMIT : @(limit),
                                };
        
        GameNetworkOutput *output = [BBSNetwork sendGetRequestWithBaseURL:[self hostURL]
                                                                   method:METHOD_GET_POST_ACTION_BY_USER
                                                               parameters:paras
                                                                 returnPB:YES
                                                          returnJSONArray:NO];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger resultCode = [output resultCode];
            NSArray *list = output.pbResponse.bbsAction;
            EXECUTE_BLOCK(handler, resultCode, list, 0);
        });
    });
}


#pragma mark- mark methods 精华帖

- (void)markPost:(PBBBSPost *)post
         handler:(BBSOperatePostHandler)handler
{
    if (post.postId == nil || post.boardId == nil) {
        return;
    }
    
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        NSDictionary *paras = @{PARA_DEVICETYPE : @(deviceType),
                                PARA_APPID : appId,
                                PARA_USERID : userId,
                                PARA_BOARDID : post.boardId,
                                PARA_POSTID : post.postId
                                };
        
        GameNetworkOutput *output = [BBSNetwork sendGetRequestWithBaseURL:[self hostURL] method:METHOD_MARK_POST parameters:paras returnPB:NO returnJSONArray:YES];        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger resultCode = [output resultCode];
            PBBBSPost *editedPost = post;
            if (resultCode == 0) {
                PBBBSPostBuilder *editedPostBuilder = [PBBBSPost builderWithPrototype:post];
                editedPostBuilder.marked = YES;
                editedPost = [editedPostBuilder build];
            }
            EXECUTE_BLOCK(handler, resultCode, editedPost);
        });
    });
}

- (void)unmarkPost:(PBBBSPost *)post
         handler:(BBSOperatePostHandler)handler
{
    if (post.postId == nil || post.boardId == nil) {
        return;
    }
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        NSDictionary *paras = @{PARA_DEVICETYPE : @(deviceType),
                                PARA_APPID : appId,
                                PARA_USERID : userId,
                                PARA_BOARDID : post.boardId,
                                PARA_POSTID : post.postId
                                };
        
        GameNetworkOutput *output = [BBSNetwork sendGetRequestWithBaseURL:[self hostURL] method:METHOD_UNMARK_POST parameters:paras returnPB:NO returnJSONArray:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger resultCode = [output resultCode];
            PBBBSPost *editedPost = post;
            if (resultCode == 0) {
                PBBBSPostBuilder *editedPostBuilder = [PBBBSPost builderWithPrototype:post];
                editedPostBuilder.marked = NO;
                editedPost = [editedPostBuilder build];
            }
            EXECUTE_BLOCK(handler, resultCode, editedPost);
        });
    });
}

- (void)getMarkedPostList:(NSString *)boardId
                   offset:(NSInteger)offset
                    limit:(NSInteger)limit
                  hanlder:(BBSGetPostResultHandler)handler
{
    dispatch_async(workingQueue, ^{
        NSInteger deviceType = [DeviceDetection deviceType];
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        NSDictionary *paras = @{PARA_DEVICETYPE : @(deviceType),
                                PARA_APPID : appId,
                                PARA_USERID : userId,
                                PARA_BOARDID : boardId,
                                PARA_OFFSET : @(offset),
                                PARA_LIMIT : @(limit)
                                };
        
        GameNetworkOutput *output = [BBSNetwork sendGetRequestWithBaseURL:[self hostURL] method:METHOD_GET_MARKED_POSTS parameters:paras returnPB:YES returnJSONArray:NO];
            
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger resultCode = [output resultCode];
            NSArray *list = [output.pbResponse bbsPost];
            EXECUTE_BLOCK(handler, resultCode, list, 0);        
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
                        opusId:(NSString *)opusId
                  opusCategory:(int)opusCategory
                       boardId:(NSString *)boardId
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
            if ([opusId length] > 0){
                if (opusCategory == PBOpusCategoryTypeSingCategory){
                    contentType = ContentTypeSingOpus;
                }
                else{
                    contentType = ContentTypeDrawOpus;
                }
            }
            else if (image) {
                contentType = ContentTypeImage;
            }
            else if (drawImage) {
                contentType = ContentTypeDraw;
                drawData = [DrawAction buildBBSDrawData:drawActionList canvasSize:size info:nil];
            }
            else{
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
            NSString *appId = [PPConfigManager appId];
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
            
            CommonNetworkOutput *output = [BBSNetwork createAction:[self hostURL]
                                                             appId:appId
                                                        deviceType:deviceType
                                                            userId:userId
                                                          nickName:nickName
                                                            gender:gender
                                                            avatar:avatar
                                                           boardId:boardId
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
                                                         drawImage:[drawImage data]
                                           
                                                            opusId:opusId
                                                      opusCategory:opusCategory];

            
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
                                                 opusId:opusId
                                           opusCategory:opusCategory
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
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getActionList:[self hostURL]
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
                list = [response bbsAction];
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
        NSString *appId = [PPConfigManager appId];
        NSString *userId = [[UserManager defaultManager] userId];
        
        CommonNetworkOutput *output = [BBSNetwork getActionList:[self hostURL]
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
                list = [response bbsAction];
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
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        PBBBSUser *aUser = action.createUser;
        
        CommonNetworkOutput *output = [BBSNetwork payReward:[self hostURL]
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
        if (draw != nil && [draw.drawActionList count] > 0) {
            PPDebug(@"<getBBSDrawDataWithPostId> load data from local service");
//            NSArray *list = [draw drawActionListList];
            NSMutableArray *drawActionList = [DrawAction drawActionListFromPBBBSDraw:draw];
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
            NSString *appId = [PPConfigManager appId];
        
            CommonNetworkOutput *output = [BBSNetwork getBBSDrawData:[self hostURL]
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
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork getBBSPost:[self hostURL]
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
                NSArray *list = [response bbsPost];
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
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork deleteBBSPost:[self hostURL]
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
            
            [self showErrorUserForbidden:resultCode];
            
        });
    });
}

- (void)showErrorUserForbidden:(int)resultCode
{
    if (resultCode == ERROR_BBS_BOARD_FORIDDEN){
        POSTMSG(NSLS(@"kUserBoardForbidden"));
    }
}

- (void)deleteActionWithActionId:(NSString *)actionId
                         boardId:(NSString *)boardId
                        delegate:(id<BBSServiceDelegate>)delegate
{
    dispatch_async(workingQueue, ^{
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork deleteBBSAction:[self hostURL]
                                                            appId:appId
                                                       deviceType:deviceType
                                                           userId:userId
                                                         actionId:actionId
                                                          boardId:boardId];
        NSInteger resultCode = [output resultCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didDeleteBBSAction:resultCode:)]) {
                [delegate didDeleteBBSAction:actionId resultCode:resultCode];
            }
            
            [self showErrorUserForbidden:resultCode];
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
        NSString *appId = [PPConfigManager appId];
        NSInteger deviceType = [DeviceDetection deviceType];
        CommonNetworkOutput *output = [BBSNetwork editBBSPost:[self hostURL]
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
            PBBBSPostBuilder  *builder = [PBBBSPost builderWithPrototype:post];
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
            
            [self showErrorUserForbidden:resultCode];
            
        });
    });
}

- (void)editPost:(PBBBSPost *)post
            text:(NSString *)text
        callback:(BBSOperatePostHandler)callback
{
    dispatch_async(workingQueue, ^{
       
        NSInteger code = [self checkWithText:text contentType:post.content.type isPost:YES];
        if (code != ERROR_SUCCESS) {
            EXECUTE_BLOCK(callback, code, nil);
            return;
        }
        
        NSDictionary *paras = @{PARA_TEXT_CONTENT:text,
                                PARA_POSTID:post.postId,
                                PARA_BOARDID:post.boardId ? post.boardId : @""
                                };
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_EDIT_BBS_POST_TEXT
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];

//       CommonNetworkOutput *output = [GameNetworkRequest sendGetRequestWithBaseURL:[self hostURL] method:METHOD_EDIT_BBS_POST_TEXT parameters:paras returnPB:NO returnArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            PBBBSPost *retPost = nil;
            if (output.resultCode == ERROR_SUCCESS) {
                PBBBSPostBuilder *retPostBuilder = [PBBBSPost builderWithPrototype:post];
                PBBBSContentBuilder *contentBuilder = [PBBBSContent builderWithPrototype:post.content];
                [contentBuilder setText:text];

                [retPostBuilder setContent:[contentBuilder build]];
                
                retPost = [retPostBuilder build];
                PPDebug(@"after edit post text, post.text = %@", retPost.content.text);
            }
            EXECUTE_BLOCK(callback, output.resultCode, retPost);

            [self showErrorUserForbidden:output.resultCode];

        });
    });
}

- (void)createBoard:(NSString*)boardName seq:(int)boardSeq resultBlock:(BBSResultHandler)resultBlock
{
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_NAME:boardName, PARA_SEQ:@(boardSeq)};
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_CREATE_BOARD
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"创建版块成功");
            }
            else{
                POSTMSG(@"创建版块失败");
            }
            PPDebug(@"<createBoard> name=%@, seq=%d, result=%d", boardName, boardSeq, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)updateBoard:(NSString*)boardId
               name:(NSString*)boardName
                seq:(int)boardSeq
        resultBlock:(BBSResultHandler)resultBlock
{
    if (boardName == nil || boardId == nil){
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_BOARDID:boardId,
                                PARA_NAME:boardName,
                                PARA_SEQ:@(boardSeq)};
        
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_UPDATE_BOARD
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"修改版块成功");
            }
            else{
                POSTMSG(@"修改版块失败");
            }
            PPDebug(@"<updateBoard> id=%@, name=%@, seq=%d, result=%d",
                    boardId, boardName, boardSeq, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)deleteBoard:(NSString*)boardId
        resultBlock:(BBSResultHandler)resultBlock
{
    if (boardId == nil){
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_BOARDID:boardId};
        
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_DELETE_BOARD
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"删除版块成功");
            }
            else{
                POSTMSG(@"删除版块失败");
            }
            PPDebug(@"<deleteBoard> id=%@, result=%d",
                    boardId, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

#define USER_BOARD_TYPE_ADMIN           4
#define USER_BOARD_TYPE_USER            0
#define USER_BOARD_TYPE_MANAGER         2
#define USER_BOARD_TYPE_REMOVE          (-1)

- (void)setUserBoardType:(NSString*)boardId
                  userId:(NSString*)userId
                    type:(int)type
             resultBlock:(BBSResultHandler)resultBlock
{
    if (boardId == nil || userId == nil){
        return;
    }
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_BOARDID:boardId,
                                PARA_TARGETUSERID:userId,
                                PARA_TYPE:@(type)};
        
        NSMutableDictionary* finalParas = [NSMutableDictionary dictionaryWithDictionary:paras];
        if (type == USER_BOARD_TYPE_REMOVE){
            [finalParas removeObjectForKey:PARA_TYPE];
        }
        
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_SET_USER_BOARD_TYPE
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"设置用户类型成功");
            }
            else{
                POSTMSG(@"设置用户类型失败");
            }
            PPDebug(@"<setUserBoardType> id=%@, userId=%@, type=%d, result=%d",
                    boardId, userId, type, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)removeBoardAdminOrManager:(NSString*)boardId userId:(NSString*)userId resultBlock:(BBSResultHandler)resultBlock
{
    [self setUserBoardType:boardId userId:userId type:USER_BOARD_TYPE_REMOVE resultBlock:resultBlock];
    [self setUserBoardType:boardId userId:userId type:USER_BOARD_TYPE_USER resultBlock:resultBlock];
}

- (void)addBoardAdmin:(NSString*)boardId userId:(NSString*)userId resultBlock:(BBSResultHandler)resultBlock
{
    [self setUserBoardType:boardId userId:userId type:USER_BOARD_TYPE_ADMIN resultBlock:resultBlock];
}

- (void)addBoardManager:(NSString*)boardId userId:(NSString*)userId resultBlock:(BBSResultHandler)resultBlock
{
    [self setUserBoardType:boardId userId:userId type:USER_BOARD_TYPE_MANAGER resultBlock:resultBlock];
}

#define FORBID_USER     1
#define UNFORBID_USER   2

- (void)forbidUser:(NSString*)targetUserId boardId:(NSString*)boardId days:(int)days resultBlock:(BBSResultHandler)resultBlock
{
    if (boardId == nil || targetUserId == nil){
        return;
    }
    
    int type = FORBID_USER;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_BOARDID:boardId,
                                PARA_TARGETUSERID:targetUserId,
                                PARA_DAY:@(days),
                                PARA_TYPE:@(type)};
        
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_FORBID_USER_BOARD
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"禁言成功");
            }
            else{
                POSTMSG(@"禁言失败");
            }
            PPDebug(@"<forbidUser> id=%@, userId=%@, type=%d, result=%d",
                    boardId, targetUserId, type, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)unforbidUser:(NSString*)targetUserId boardId:(NSString*)boardId days:(int)days resultBlock:(BBSResultHandler)resultBlock
{
    if (boardId == nil || targetUserId == nil){
        return;
    }
    
    int type = UNFORBID_USER;
    
    dispatch_async(workingQueue, ^{
        
        NSDictionary *paras = @{PARA_BOARDID:boardId,
                                PARA_TARGETUSERID:targetUserId,
                                PARA_DAY:@(days),
                                PARA_TYPE:@(type)};
        
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:[self hostURL]
                                     method:METHOD_FORBID_USER_BOARD
                                     parameters:paras
                                     returnPB:NO
                                     returnJSONArray:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == ERROR_SUCCESS) {
                POSTMSG(@"解除禁言成功");
            }
            else{
                POSTMSG(@"解除禁言失败");
            }
            PPDebug(@"<forbidUser> id=%@, userId=%@, type=%d, result=%d",
                    boardId, targetUserId, type, output.resultCode);
            EXECUTE_BLOCK(resultBlock, output.resultCode);
        });
    });
}

- (void)getStagePost:(NSString *)tutorialId
             stageId:(NSString *)stageId
        tutorialName:(NSString *)tutorialName
           stageName:(NSString *)stageName
      fromController:(PPViewController *)fromController
{

    if(tutorialId == nil){
        PPDebug(@"<getStagePost> tutorialId is nil");
        return;
    }
    
    if(stageId == nil){
        PPDebug(@"<getStagePost> stageId is nil");
        return;
    }
    
    NSMutableDictionary* para = [[[NSMutableDictionary alloc] init] autorelease];
    [para setValue:tutorialId forKey:PARA_TUTORIAL_ID];
    [para setValue:stageId forKey:PARA_STAGE_ID];
    
    if (tutorialName){
        [para setObject:tutorialName forKey:PARA_TUTORIAL_NAME];
    }
    
    if (stageName){
        [para setObject:stageName forKey:PARA_STAGE_NAME];
    }

    [fromController showActivityWithText:NSLS(@"kLoading")];
    [PPGameNetworkRequest loadPBData:workingQueue
                             hostURL:TUTORIAL_HOST
                              method:METHOD_GET_STAGE_POST_ID
                          parameters:para
                            callback:^(DataQueryResponse *response, NSError *error) {
                                [fromController hideActivity];
                                if (error == nil){
                                    NSArray *bbsPostList = response.bbsPost;
                                    if ([bbsPostList count] > 0){
                                        PBBBSPost *pbBBSPost = [bbsPostList objectAtIndex:0];
                                        PPDebug(@"<getStagePost> postId=%@ success", pbBBSPost.postId);
                                        [BBSPostDetailController enterPostDetailControllerWithPost:pbBBSPost
                                                                                    fromController:fromController
                                                                                          animated:YES];
                                        
                                    }
                                }
                                
                                
                            } isPostError:YES
     ];

}


@end
