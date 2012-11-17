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


#pragma mark - change data with remote.

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
        }
        @finally {
            list = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didGetBBSBoardList:resultCode:)]) {
                [delegate didGetBBSBoardList:list resultCode:resultCode];
            }
        });
    });
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
                                                    imageUrl:nil
                                               thumbImageUrl:nil
                                                drawImageUrl:nil
                                           drawImageThumbUrl:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate && [delegate respondsToSelector:@selector(didCreatePost:resultCode:)]) {
                [delegate didCreatePost:post resultCode:output.resultCode];
            }
        });
    });
}

@end
