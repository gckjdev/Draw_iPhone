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
                            email:(NSString*)email 
                         password:(NSString*)password 
                      deviceToken:(NSString*)deviceToken;

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                          deviceId:(NSString*)deviceId
                       deviceToken:(NSString*)deviceToken
                          nickName:(NSString*)nickName
                          password:(NSString*)newPassword
                            avatar:(NSData*)avatar;

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
                                  amount:(int)amount;

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
                             userId:(NSString*)userId
                               type:(int)type 
                         startIndex:(NSInteger)startIndex 
                           endIndex:(NSInteger)endIndex;

+ (CommonNetworkOutput*)searchUsers:(NSString*)baseURL
                              appId:(NSString*)appId
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

+ (CommonNetworkOutput*)findDrawWithProtocolBuffer:(NSString*)baseURL;

@end
