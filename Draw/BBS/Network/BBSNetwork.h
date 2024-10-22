//
//  BBSNetwork.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "GameNetworkConstants.h"
#import "PPNetworkConstants.h"
#import "PPGameNetworkRequest.h"
@class CommonNetworkOutput;


@interface BBSNetwork : PPGameNetworkRequest

+ (CommonNetworkOutput*)getBBSBoardList:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                             deviceType:(int)deviceType
                                 gameId:(NSString *)gameId
                               language:(int)language;


#pragma mark - post methods
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
                            opusId:(NSString *)opusId
                      opusCategory:(int)opusCategory
                             bonus:(NSInteger)bonus
                         isPrivate:(BOOL)isPrivate;

+ (CommonNetworkOutput*)getPostList:(NSString*)baseURL
                              appId:(NSString*)appId
                         deviceType:(int)deviceType
                             userId:(NSString*)userId
                          targetUid:(NSString*)targetUid
                            boardId:(NSString*)boardId
                          rangeType:(NSInteger)rangeType
                             offset:(NSInteger)offset
                              limit:(NSInteger)limit;

+ (CommonNetworkOutput*)searchPostList:(NSString*)baseURL
                                 appId:(NSString*)appId
                            deviceType:(int)deviceType
                                userId:(NSString*)userId
                               boardId:(NSString*)boardId
                               keyWord:(NSString*)keyWord
                                 limit:(NSInteger)limit;

+ (CommonNetworkOutput*)createAction:(NSString*)baseURL
                               appId:(NSString*)appId
                          deviceType:(int)deviceType
//user info
                              userId:(NSString*)userId
                            nickName:(NSString*)nickName
                              gender:(NSString*)gender
                              avatar:(NSString*)avatar
                             boardId:(NSString*)boardId
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
                              opusId:(NSString *)opusId
                        opusCategory:(int)opusCategory;


+ (CommonNetworkOutput*)getActionList:(NSString*)baseURL
                                appId:(NSString *)appId
                           deviceType:(NSInteger)deviceType
                               userId:(NSString *)userId
                            targetUid:(NSString *)targetUid
                               postId:(NSString *)postId
                           actionType:(NSInteger)actionType
                               offset:(NSInteger)offset
                                limit:(NSInteger)limit;

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
                     actionAvatar:(NSString *)actionAvatar;

//delete method
+ (CommonNetworkOutput*)deleteBBSPost:(NSString*)baseURL
                                appId:(NSString *)appId
                           deviceType:(NSInteger)deviceType
                               userId:(NSString *)userId
                               postId:(NSString *)postId
                              boardId:(NSString *)boardId;

+ (CommonNetworkOutput*)deleteBBSAction:(NSString*)baseURL
                                  appId:(NSString *)appId
                             deviceType:(NSInteger)deviceType
                                 userId:(NSString *)userId
                               actionId:(NSString *)actionId
                                boardId:(NSString *)boardId;

+ (CommonNetworkOutput*)getBBSPost:(NSString*)baseURL
                             appId:(NSString *)appId
                        deviceType:(NSInteger)deviceType
                            userId:(NSString *)userId
                            postId:(NSString *)postId;

+ (CommonNetworkOutput*)getBBSPrivilegeList:(NSString*)baseURL
                                      appId:(NSString *)appId
                                 deviceType:(NSInteger)deviceType
                                     userId:(NSString *)userId;

+ (CommonNetworkOutput*)changeBBSUserRole:(NSString*)baseURL
                                    appId:(NSString *)appId
                               deviceType:(NSInteger)deviceType
                                   userId:(NSString *)userId
                                targetUid:(NSString *)targetUid
                                  boardId:(NSString *)boardId
                                 roleType:(int)roleType
                               expireDate:(NSDate *)expireDate
                                     info:(NSDictionary *)info; //for the future

+ (CommonNetworkOutput*)getBBSDrawData:(NSString*)baseURL
                                 appId:(NSString *)appId
                            deviceType:(NSInteger)deviceType
                                userId:(NSString *)userId
                                postId:(NSString *)postId
                              actionId:(NSString *)actionId;

+ (CommonNetworkOutput*)editBBSPost:(NSString*)baseURL
                              appId:(NSString *)appId
                         deviceType:(NSInteger)deviceType
                             userId:(NSString *)userId
                             postId:(NSString *)postId
                            boardId:(NSString *)boardId
                             status:(int)status
                               info:(NSDictionary *)info; //for the future

@end
