//
//  GameNetworkRequest.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CommonNetworkOutput;


@interface GameNetworkRequest : NSObject

+ (CommonNetworkOutput*)registerUserByEmail:(NSString*)baseURL
                                      appId:(NSString*)appId
                                      email:(NSString*)email
                                   password:(NSString*)password
                                deviceToken:(NSString*)deviceToken;

+ (CommonNetworkOutput*)registerUserBySNS:(NSString*)baseURL
                                    snsId:(NSString*)snsId
                             registerType:(int)registerType                                      
                                    appId:(NSString*)appId
                              deviceToken:(NSString*)deviceToken
                                 nickName:(NSString*)nickName
                                   avatar:(NSString*)avatar
                              accessToken:(NSString*)accessToken
                        accessTokenSecret:(NSString*)accessTokenSecret
                                 province:(int)province
                                     city:(int)city
                                 location:(NSString*)location
                                   gender:(NSString*)gender
                                 birthday:(NSString*)birthday
                                   domain:(NSString*)domain;

+ (CommonNetworkOutput*)registerUserByEmail:(NSString*)baseURL
                                      appId:(NSString*)appId
                                      email:(NSString*)email
                                   password:(NSString*)password
                                deviceToken:(NSString*)deviceToken 
                                   deviceId:(NSString*)deviceId;

+ (CommonNetworkOutput*)registerUserBySNS:(NSString*)baseURL
                                    snsId:(NSString*)snsId
                             registerType:(int)registerType                                      
                                    appId:(NSString*)appId
                              deviceToken:(NSString*)deviceToken
                                 nickName:(NSString*)nickName
                                   avatar:(NSString*)avatar
                              accessToken:(NSString*)accessToken
                        accessTokenSecret:(NSString*)accessTokenSecret
                                 province:(int)province
                                     city:(int)city
                                 location:(NSString*)location
                                   gender:(NSString*)gender
                                 birthday:(NSString*)birthday
                                   domain:(NSString*)domain 
                                 deviceId:(NSString*)deviceId;

+ (CommonNetworkOutput*)loginUser:(NSString*)baseURL
                            appId:(NSString*)appId 
                           gameId:(NSString*)gameId
                            email:(NSString*)email 
                         password:(NSString*)password 
                      deviceToken:(NSString*)deviceToken;

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                          deviceId:(NSString*)deviceId
                       deviceToken:(NSString*)deviceToken
                          nickName:(NSString*)nickName
                            gender:(NSString*)gender
                             email:(NSString *)email
                          password:(NSString*)newPassword
                            avatar:(NSData*)avatar;

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                            userId:(NSString*)userId
                             appId:(NSString*)appId
                          newAppId:(NSString*)newAppId;

+ (CommonNetworkOutput*)fetchShoppingList:(NSString*)baseURL 
                                     type:(int)type;
+ (CommonNetworkOutput*)fetchAccountBalance:(NSString*)baseURL userId:(NSString *)userId;

+ (CommonNetworkOutput*)getAllTrafficeServers:(NSString*)baseURL;

+ (CommonNetworkOutput*)chargeAccount:(NSString*)baseURL
                               userId:(NSString*)userId
                               amount:(int)amount
                               source:(int)source
                        transactionId:(NSString*)transactionId
                   transactionReceipt:(NSString*)transactionRecepit;

+ (CommonNetworkOutput*)deductAccount:(NSString*)baseURL
                               userId:(NSString*)userId
                               amount:(int)amount
                               source:(int)source;

+ (CommonNetworkOutput*)updateItemAmount:(NSString*)baseURL
                                  userId:(NSString*)userId
                                itemType:(int)itemType
                                  amount:(int)amount
                            targetUserId:(NSString*)targetUserId
                             awardAmount:(int)awardAmount
                                awardExp:(int)awardExp;

+ (CommonNetworkOutput*)updateBalance:(NSString*)baseURL
                                  userId:(NSString*)userId
                              balance:(int)balance;


+ (CommonNetworkOutput*)syncUserAccontAndItem:(NSString*)baseURL
                                       userId:(NSString*)userId;
+ (CommonNetworkOutput*)syncUserAccontAndItem:(NSString*)baseURL 
                                       userId:(NSString*)userId 
                                     deviceId:(NSString*)deviceId;

+ (CommonNetworkOutput*)feedbackUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId 
                            feedback:(NSString*)feedback 
                             contact:(NSString*)contact
                              type:(int)type;

+ (CommonNetworkOutput*)loginUser:(NSString*)baseURL
                            appId:(NSString*)appId 
                           gameId:(NSString*)gameId
                         deviceId:(NSString*)deviceId
                      deviceToken:(NSString*)deviceToken;

+ (CommonNetworkOutput*)followUser:(NSString*)baseURL
                             appId:(NSString*)appId 
                            userId:(NSString*)userId
                 targetUserIdArray:(NSArray*)targetUserIdArray;

+ (CommonNetworkOutput*)unFollowUser:(NSString*)baseURL
                               appId:(NSString*)appId
                              userId:(NSString*)userId
                   targetUserIdArray:(NSArray*)targetUserIdArray;

+ (CommonNetworkOutput*)findFriends:(NSString*)baseURL
                              appId:(NSString*)appId 
                             gameId:(NSString*)gameId
                             userId:(NSString*)userId
                               type:(int)type 
                         startIndex:(NSInteger)startIndex 
                           endIndex:(NSInteger)endIndex;

+ (CommonNetworkOutput*)searchUsers:(NSString*)baseURL
                              appId:(NSString*)appId 
                             gameId:(NSString*)gameId
                          keyString:(NSString*)keyString 
                         startIndex:(NSInteger)startIndex 
                           endIndex:(NSInteger)endIndex;

+ (CommonNetworkOutput*)createRoom:(NSString*)baseURL 
                          roomName:(NSString *)roomName  
                          password:(NSString *)password 
                            userId:(NSString *)userId 
                              nick:(NSString *)nick 
                            avatar:(NSString *)avatar 
                            gender:(NSString *)gender;

+ (CommonNetworkOutput*)findRoomByUser:(NSString*)baseURL 
                                userId:(NSString *)userId 
                                offset:(NSInteger)offset
                                 limit:(NSInteger)limit;

+ (CommonNetworkOutput*)searhRoomWithKey:(NSString*)baseURL 
                                 keyword:(NSString *)keyword 
                                  offset:(NSInteger)offset
                                   limit:(NSInteger)limit;

+ (CommonNetworkOutput*)inviteUsersToRoom:(NSString*)baseURL 
                                   roomId:(NSString *)roomId                   
                                 password:(NSString *)password                   
                                   userId:(NSString *)userId                              
                                 userList:(NSString *)userList;

+ (CommonNetworkOutput*)removeRoom:(NSString*)baseURL 
                                   roomId:(NSString *)roomId                   
                                 password:(NSString *)password                   
                                   userId:(NSString *)userId;

+ (CommonNetworkOutput*)uninvitedJoinRoom:(NSString*)baseURL 
                                   roomId:(NSString *)roomId  
                                 password:(NSString *)password 
                                   userId:(NSString *)userId 
                                     nick:(NSString *)nick 
                                   avatar:(NSString *)avatar 
                                   gender:(NSString *)gender;

+ (CommonNetworkOutput*)commitWords:(NSString*)baseURL 
                              appId:(NSString*)appId 
                             userId:(NSString*)userId 
                              words:(NSString*)words;

+ (CommonNetworkOutput*)syncExpAndLevel:(NSString*)baseURL 
                                  appId:(NSString*)appId 
                                 gameId:(NSString*)gameId
                                 userId:(NSString*)userId 
                                  level:(int)level 
                                    exp:(long)exp 
                                   type:(int)type;

+ (CommonNetworkOutput*)findDrawWithProtocolBuffer:(NSString*)baseURL;

+ (CommonNetworkOutput*)matchDrawWithProtocolBuffer:(NSString*)baseURL 
                                             userId:(NSString *)userId 
                                             gender:(NSString *)gender 
                                               lang:(int)lang
                                               type:(NSInteger)type;

+ (CommonNetworkOutput*)createOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                              nick:(NSString*)nick
                            avatar:(NSString*)avatar
                            gender:(NSString*)gender
                              word:(NSString *)word
                             level:(NSInteger)level
                              lang:(NSInteger)lang
                              data:(NSData*)data 
                         targetUid:(NSString *)targetUid;

+ (CommonNetworkOutput*)guessOpus:(NSString*)baseURL
                            appId:(NSString*)appId
                           userId:(NSString*)userId
                             nick:(NSString*)nick
                           avatar:(NSString*)avatar
                           gender:(NSString*)gender
                           opusId:(NSString*)opusId                        
                   opusCreatorUId:(NSString*)opusCreatorUId  
                        isCorrect:(BOOL)isCorrect
                            score:(NSInteger)score
                            words:(NSString*)words;

+ (CommonNetworkOutput*)commentOpus:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                               nick:(NSString*)nick
                             avatar:(NSString*)avatar
                             gender:(NSString*)gender
                             opusId:(NSString*)opusId                        
                     opusCreatorUId:(NSString*)opusCreatorUId  
                            comment:(NSString*)comment;

+ (CommonNetworkOutput*)throwItemToOpus:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                                   nick:(NSString*)nick
                                 avatar:(NSString*)avatar
                                 gender:(NSString*)gender
                                 opusId:(NSString*)opusId                        
                         opusCreatorUId:(NSString*)opusCreatorUId  
                               itemType:(int)itemType;


+ (CommonNetworkOutput*)getUserMessage:(NSString*)baseURL
                                 appId:(NSString*)appId
                                userId:(NSString*)userId
                          friendUserId:(NSString*)friendUserId
                           startOffset:(int)startOffset
                              maxCount:(int)maxCount;

+ (CommonNetworkOutput*)sendMessage:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                       targetUserId:(NSString*)targetUserId
                               text:(NSString*)text
                               data:(NSData*)data;
+ (CommonNetworkOutput*)userHasReadMessage:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId 
                              friendUserId:(NSString*)friendUserId;

+ (CommonNetworkOutput*)getFeedListWithProtocolBuffer:(NSString*)baseURL 
                                               userId:(NSString *)userId 
                                         feedListType:(NSInteger)feedListType
                                               offset:(NSInteger)offset
                                                limit:(NSInteger)limit 
                                                 lang:(NSInteger)lang;

+ (CommonNetworkOutput*)getFeedCommentListWithProtocolBuffer:(NSString*)baseURL 
                                                      opusId:(NSString *)opusId 
                                                      offset:(NSInteger)offset
                                                       limit:(NSInteger)limit;

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                          deviceId:(NSString*)deviceId
                       deviceToken:(NSString*)deviceToken
                          nickName:(NSString*)nickName
                            gender:(NSString*)gender
                          password:(NSString*)newPassword
                            avatar:(NSString*)avatar 
                          location:(NSString*)location 
                            sinaId:(NSString*)sinaId 
                      sinaNickName:(NSString*)sinaNickName
                         sinaToken:(NSString*)sinaToken 
                        sinaSecret:(NSString*)sinaSecret 
                              qqId:(NSString*)qqId 
                        qqNickName:(NSString*)qqNickName
                           qqToken:(NSString*)qqToken 
                     qqTokenSecret:(NSString*)qqTokenSecret 
                        facebookId:(NSString*)facebookId 
                             email:(NSString*)email;

+ (CommonNetworkOutput*)getStatistics:(NSString*)baseURL 
                                appId:(NSString *)appId 
                               userId:(NSString *)userId;

+ (CommonNetworkOutput*)deleteMessage:(NSString*)baseURL 
                                appId:(NSString*)appId
                               userId:(NSString*)userId
                 targetMessageIdArray:(NSArray*)targetMessageIdArray;

+ (CommonNetworkOutput*)deleteMessageStat:(NSString*)baseURL 
                                    appId:(NSString*)appId
                                   userId:(NSString*)userId
                             targetUserId:(NSString*)targetUserId;

+ (CommonNetworkOutput*)getUserSimpleInfo:(NSString*)baseURL 
                                    appId:(NSString*)appId 
                                   gameId:(NSString*)gameId
                                 ByUserId:(NSString*)targetUserId;

+ (CommonNetworkOutput*)deleteFeed:(NSString*)baseURL 
                             appId:(NSString*)appId
                            feedId:(NSString*)feedId 
                            userId:(NSString *)userId;

@end
