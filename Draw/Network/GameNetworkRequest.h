//
//  GameNetworkRequest.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameConstants.pb.h"
#import "GameBasic.pb.h"
#import "GameMessage.pb.h"
#import "PPNetworkRequest.h"
#import "PPGameNetworkRequest.h"

@class MyPaint;

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
                             refreshToken:(NSString*)refreshToken
                               expireDate:(NSDate*)expireDate
                                 qqOpenId:(NSString*)qqOpenId
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
                             refreshToken:(NSString*)refreshToken
                               expireDate:(NSDate*)expireDate
                                 qqOpenId:(NSString*)qqOpenId
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

+ (CommonNetworkOutput*)chargeCoin:(NSString*)baseURL
                            userId:(NSString*)userId
                            amount:(int)amount
                            source:(int)source
                     transactionId:(NSString*)transactionId
                transactionReceipt:(NSString*)transactionRecepit;

+ (CommonNetworkOutput*)chargeCoin:(NSString*)baseURL
                            userId:(NSString*)userId
                            amount:(int)amount
                            source:(int)source
                     transactionId:(NSString*)transactionId
                transactionReceipt:(NSString*)transactionRecepit
                            byUser:(NSString*)byUserId
                         alixOrder:(NSString *)alixOrder;

+ (CommonNetworkOutput*)chargeIngot:(NSString*)baseURL
                             userId:(NSString*)userId
                             amount:(int)amount
                             source:(int)source
                      transactionId:(NSString*)transactionId
                 transactionReceipt:(NSString*)transactionRecepit
                             byUser:(NSString*)byUserId
                          alixOrder:(NSString *)alixOrder;

+ (CommonNetworkOutput*)deductCoin:(NSString*)baseURL
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

+ (CommonNetworkOutput*)newLoginUser:(NSString*)baseURL
                               appId:(NSString*)appId
                              gameId:(NSString*)gameId
                            deviceId:(NSString*)deviceId
                         deviceToken:(NSString*)deviceToken
                        autoRegister:(BOOL)autoRegister
                        returnXiaoji:(BOOL)returnXiaoji;

+ (CommonNetworkOutput*)newLoginUser:(NSString*)baseURL
                               appId:(NSString*)appId
                              gameId:(NSString*)gameId
                               email:(NSString*)email
                            password:(NSString*)password
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

//new get friend list interface.
+ (CommonNetworkOutput*)getFriendList:(NSString*)baseURL
                                appId:(NSString*)appId 
                               gameId:(NSString*)gameId
                               userId:(NSString*)userId
                                 type:(NSInteger)type 
                               offset:(NSInteger)offset 
                                limit:(NSInteger)limit;

+ (CommonNetworkOutput*)getRelationCount:(NSString*)baseURL
                                   appId:(NSString*)appId
                                  gameId:(NSString*)gameId
                                  userId:(NSString*)userId;

+ (CommonNetworkOutput*)searchUsers:(NSString*)baseURL
                              appId:(NSString*)appId 
                             gameId:(NSString*)gameId
                             userId:(NSString*)userId
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
                                   type:(int)type
                               awardExp:(long)awardExp;

+ (CommonNetworkOutput*)findDrawWithProtocolBuffer:(NSString*)baseURL;

+ (CommonNetworkOutput*)matchDrawWithProtocolBuffer:(NSString*)baseURL 
                                             userId:(NSString *)userId 
                                             gender:(NSString *)gender 
                                               lang:(int)lang
                                               type:(NSInteger)type;

+ (CommonNetworkOutput*)getFeedWithProtocolBuffer:(NSString*)baseURL 
                                           userId:(NSString *)userId 
                                           feedId:(NSString *)feedId;



+ (CommonNetworkOutput*)createOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                              nick:(NSString*)nick
                            avatar:(NSString*)avatar
                         signature:(NSString*)signature
                            gender:(NSString*)gender
                            wordId:(NSString*)wordId
                              word:(NSString *)word
                          wordType:(PBWordType)wordType
                             level:(NSInteger)level
                             score:(int)score
                              lang:(NSInteger)lang
                              data:(NSData*)data
                         imageData:(NSData *)imageData
                       bgImageData:(NSData *)bgImageData
                         targetUid:(NSString *)targetUid
                         contestId:(NSString *)contestId
                              desc:(NSString *)desc
                             draft:(MyPaint *)draft
                         userStage:(PBUserStage *)userStage
                      userTutorial:(PBUserTutorial *)userTutorial
                      isCompressed:(BOOL)isCompressed
                  progressDelegate:(id)progressDelegate;



+ (CommonNetworkOutput*)updateOpus:(NSString*)baseURL
                             appId:(NSString*)appId
                            userId:(NSString*)userId
                            opusId:(NSString*)opusId
                              data:(NSData*)data
                         imageData:(NSData *)imageData
                      isCompressed:(BOOL)isCompressed
                       description:(NSString*)description;

+ (CommonNetworkOutput*)rejectOpusDrawToMe:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId
                                    opusId:(NSString*)opusId
                                      type:(int)newType;

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
                            words:(NSString*)words
                         category:(PBOpusCategoryType)category
                              vip:(int)vip;

+ (CommonNetworkOutput*)commentOpus:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                               nick:(NSString*)nick
                             avatar:(NSString*)avatar
                             gender:(NSString*)gender
                             opusId:(NSString*)opusId                        
                     opusCreatorUId:(NSString*)opusCreatorUId  
                            comment:(NSString*)comment 
                        commentType:(int)commentType //comment info
                          commentId:(NSString *)commentId 
                     commentSummary:(NSString *)commentSummary
                      commentUserId:(NSString *)commentUserId 
                    commentNickName:(NSString *)commentNickName
                          contestId:(NSString*)contestId
                           category:(PBOpusCategoryType)category
                                vip:(int)vip;;

+ (CommonNetworkOutput*)contestCommentOpus:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId
                                      nick:(NSString*)nick
                                    avatar:(NSString*)avatar
                                    gender:(NSString*)gender
                                    opusId:(NSString*)opusId
                            opusCreatorUId:(NSString*)opusCreatorUId
                                   comment:(NSString*)comment
                               commentType:(int)commentType //comment info
                                 commentId:(NSString *)commentId
                            commentSummary:(NSString *)commentSummary
                             commentUserId:(NSString *)commentUserId
                           commentNickName:(NSString *)commentNickName
                                 contestId:(NSString*)contestId
                                  category:(PBOpusCategoryType)category
                                       vip:(int)vip;

+ (CommonNetworkOutput*)getOpusCount:(NSString*)baseURL
                               appId:(NSString*)appId
                              userId:(NSString*)userId
                           targetUid:(NSString*)targetUid;

+ (CommonNetworkOutput*)throwItemToOpus:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                                   nick:(NSString*)nick
                                 avatar:(NSString*)avatar
                                 gender:(NSString*)gender
                                 opusId:(NSString*)opusId                        
                         opusCreatorUId:(NSString*)opusCreatorUId  
                               itemType:(int)itemType
                           awardBalance:(int)awardBalance
                               awardExp:(int)awardExp
                              contestId:(NSString*)contestId
                               category:(PBOpusCategoryType)category
                                    vip:(int)vip;


+ (CommonNetworkOutput*)getMessageList:(NSString*)baseURL
                                 appId:(NSString*)appId
                                userId:(NSString*)userId
                          friendUserId:(NSString*)friendUserId
                       offsetMessageId:(NSString *)messageId
                              maxCount:(int)maxCount
                               forward:(BOOL)forward
                               isGroup:(BOOL)isGroup;

+ (CommonNetworkOutput*)getMessageStatList:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId
                                    offset:(int)offset
                                  maxCount:(int)maxCount;

+ (CommonNetworkOutput*)sendMessage:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                       targetUserId:(NSString*)targetUserId
                               text:(NSString*)text
                               data:(NSData*)data
                               type:(int)type
                        hasLocation:(BOOL)hasLocation
                          longitude:(double)longitude
                           latitude:(double)latitude
                       reqMessageId:(NSString*)reqMessageId
                        replyResult:(int)replyResult
                            isGroup:(BOOL)isGroup;

+ (CommonNetworkOutput*)userHasReadMessage:(NSString*)baseURL
                                     appId:(NSString*)appId
                                    userId:(NSString*)userId 
                              friendUserId:(NSString*)friendUserId;

+ (CommonNetworkOutput*)getFeedListWithProtocolBuffer:(NSString*)baseURL 
                                               userId:(NSString *)userId 
                                         feedListType:(NSInteger)feedListType
                                              classId:(NSString *)classId
                                           tutorialId:(NSString*)tutorialId
                                              stageId:(NSString*)stageId
                                               offset:(NSInteger)offset
                                                limit:(NSInteger)limit 
                                                 lang:(NSInteger)lang;

+ (CommonNetworkOutput*)getFeedListWithProtocolBuffer:(NSString*)baseURL
                                               userId:(NSString *)userId
                                         feedListType:(NSInteger)feedListType
                                              classId:(NSString *)classId
                                               offset:(NSInteger)offset
                                                limit:(NSInteger)limit
                                                 lang:(NSInteger)lang;

+ (CommonNetworkOutput*)getContestOpusListWithProtocolBuffer:(NSString*)baseURL
                                                   contestId:(NSString *)contestId
                                                      userId:(NSString *)userId 
                                                        type:(NSInteger)type
                                                      offset:(NSInteger)offset
                                                       limit:(NSInteger)limit 
                                                        lang:(NSInteger)lang;

+ (CommonNetworkOutput*)getFeedCommentListWithProtocolBuffer:(NSString*)baseURL 
                                                      opusId:(NSString *)opusId
                                                        type:(int)type
                                                      offset:(NSInteger)offset
                                                       limit:(NSInteger)limit;

+ (CommonNetworkOutput*)getMyCommentListWithProtocolBuffer:(NSString*)baseURL 
                                                    userId:(NSString *)userId
                                                     appId:(NSString *)appId
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
                  sinaRefreshToken:(NSString*)sinaRefreshToken
                    sinaExpireDate:(NSDate*)sinaExpireDate
                              qqId:(NSString*)qqId
                        qqNickName:(NSString*)qqNickName
                           qqToken:(NSString*)qqToken
                     qqTokenSecret:(NSString*)qqTokenSecret
                    qqRefreshToken:(NSString*)qqRefreshToken
                      qqExpireDate:(NSDate*)qqExpireDate
                          qqOpenId:(NSString*)qqOpenId
                        facebookId:(NSString*)facebookId
               facebookAccessToken:(NSString*)facebookAccessToken
                facebookExpireDate:(NSDate*)facebookExpireDate
                             email:(NSString *)email;

+ (CommonNetworkOutput*)getStatistics:(NSString*)baseURL 
                                appId:(NSString *)appId 
                               userId:(NSString *)userId
                              groupId:(NSString*)groupId;

+ (CommonNetworkOutput*)getOpusTimes:(NSString*)baseURL 
                               appId:(NSString *)appId 
                              feedId:(NSString *)feedId;

+ (CommonNetworkOutput*)deleteMessage:(NSString*)baseURL 
                                appId:(NSString*)appId
                               userId:(NSString*)userId
                 targetMessageIdArray:(NSArray*)targetMessageIdArray;

+ (CommonNetworkOutput*)deleteMessageStat:(NSString*)baseURL 
                                    appId:(NSString*)appId
                                   userId:(NSString*)userId
                             targetUserId:(NSString*)targetUserId;

+ (CommonNetworkOutput*)getUserListSimpleInfo:(NSString*)baseURL
                                       userId:(NSString *)userId
                                        appId:(NSString*)appId
                                       gameId:(NSString*)gameId
                                    ByUserIds:(NSString*)targetUserIds;

+ (CommonNetworkOutput*)getUserSimpleInfo:(NSString*)baseURL
                                   userId:(NSString *)userId
                                    appId:(NSString*)appId 
                                   gameId:(NSString*)gameId
                                 ByUserId:(NSString*)targetUserId;

// return by Protocol Buffer
+ (CommonNetworkOutput*)getUserInfo:(NSString*)baseURL
                             userId:(NSString *)userId
                              appId:(NSString*)appId
                             gameId:(NSString*)gameId
                           ByUserId:(NSString*)targetUserId;

+ (CommonNetworkOutput*)deleteFeed:(NSString*)baseURL
                             appId:(NSString*)appId
                            feedId:(NSString*)feedId 
                            userId:(NSString *)userId;

+ (CommonNetworkOutput*)actionSaveOnOpus:(NSString*)baseURL                                  
                                   appId:(NSString*)appId                                 
                                  userId:(NSString*)userId
                              actionType:(int)actionType
                              actionName:(NSString*)actionName
                                  opusId:(NSString*)opusId
                               contestId:(NSString *)contestId
                                category:(PBOpusCategoryType)category
                                     vip:(int)vip;

+ (CommonNetworkOutput*)reportStatus:(NSString*)baseURL 
                               appId:(NSString *)appId                                
                              userId:(NSString *)userId
                              status:(int)status;

+ (CommonNetworkOutput*)getRecommendApp:(NSString*)baseURL;

+ (CommonNetworkOutput*)getContests:(NSString*)baseURL
                              appId:(NSString*)appId
                             userId:(NSString*)userId
                               type:(NSInteger)type
                             offset:(NSInteger)offset
                             limit:(NSInteger)limit
                           language:(NSInteger)language;

+ (CommonNetworkOutput*)getTopPalyerList:(NSString*)baseURL 
                                   appId:(NSString*)appId 
                                  gameId:(NSString*)gameId 
                                  userId:(NSString *)userId
                                    type:(int)type
                                  offset:(NSInteger)offset
                                   limit:(NSInteger)limit;


// for wall

+ (CommonNetworkOutput *)createWall:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                              data:(NSData *)data
                         imageData:(NSData *)imageData;

+ (CommonNetworkOutput *)updateWall:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                            wallId:(NSString *)wallId
                              data:(NSData *)data
                         imageData:(NSData *)imageData;

//+ (CommonNetworkOutput *)deleteWall:(NSString *)baseURL
//                             appId:(NSString *)appId
//                            userId:(NSString *)userId
//                            wallId:(int)wallId;


+ (CommonNetworkOutput *)getWall:(NSString *)baseURL
                          appId:(NSString *)appId
                         userId:(NSString *)userId
                         wallId:(NSString *)wallId;


+ (CommonNetworkOutput *)getWalls:(NSString *)baseURL
                           appId:(NSString *)appId
                          userId:(NSString *)userId
                        wallType:(PBWallType)wallType;


// black user
+ (CommonNetworkOutput *)blackUser:(NSString*)baseURL
                            appId:(NSString* )appId
                     targetUserId:(NSString*)targetUserId
                           userId:(NSString*)userId
                   targetDeviceId:(NSString*)targetDeviceId
                             type:(int)type
                       actionType:(int)actionType;

//black friend
+ (CommonNetworkOutput*)blackFriend:(NSString*)baseURL
                              appId:(NSString* )appId
                       targetUserId:(NSString*)targetUserId
                             userId:(NSString*)userId
                         actionType:(int)actionType;


// buy item
+ (CommonNetworkOutput *)buyItem:(NSString *)baseURL
                           appId:(NSString *)appId
                          userId:(NSString *)userId
                          itemId:(int)itemId
                           count:(int)count
                           price:(int)price
                        currency:(PBGameCurrency)currency
                          toUser:(NSString *)toUser;

// consume item
+ (CommonNetworkOutput *)consumeItem:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                              itemId:(int)itemId
                               count:(int)count
                            forceBuy:(BOOL)forceBuy // 若不够钱是否强制购买后消耗
                               price:(int)price
                            currency:(PBGameCurrency)currency;

+ (CommonNetworkOutput*)updateUser:(NSString*)baseURL
                             appId:(NSString* )appId
                            userId:(NSString*)userId
                              data:(NSData*)data;

+ (CommonNetworkOutput*)uploadUserImage:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                              imageData:(NSData*)imageData
                              imageType:(NSString*)imageType;

+ (CommonNetworkOutput*)increaseExp:(NSString*)baseURL
                              appId:(NSString*)appId
                             gameId:(NSString*)gameId
                             userId:(NSString*)userId
                                exp:(long)addExp;


+ (CommonNetworkOutput*)sendGetRequestWithBaseURL:(NSString*)baseURL
                                           method:(NSString *)method
                                       parameters:(NSDictionary *)parameters
                                         returnPB:(BOOL)returnPB
                                      returnArray:(BOOL)returnArray;


#define URL_GOOGLE_GEOCODE_JSON     @"http://maps.googleapis.com/maps/api/geocode/json?"
#define PARA_GOOGLE_LATLNG          @"latlng"
#define PARA_GOOGLE_SENSOR          @"sensor"
#define PARA_GOOGLE_LANGUAGE        @"language"

#define GOOGLE_LANGUAGE_EN                 @"en"


+ (CommonNetworkOutput*)queryGeocodeWithLatitude:(double)latitude
                                       longitude:(double)longitude
                                        language:(NSString *)language;



+ (CommonNetworkOutput*)submitOpus:(NSString *)baseURL
                             appId:(NSString *)appId
                            userId:(NSString *)userId
                      opusMetaData:(NSData *)opusMetaData
                         imageData:(NSData *)imageData
                          opusData:(NSData *)opusData
                  progressDelegate:(id)progressDelegate;

+ (CommonNetworkOutput*)addUserPhoto:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                                data:(NSData*)data;

+ (CommonNetworkOutput*)getUserPhoto:(NSString *)baseURL
                               appId:(NSString *)appId
                              userId:(NSString *)userId
                            tagArray:(NSString *)tagArrayString
                               usage:(int)usage
                              offset:(int)offset
                               limit:(int)limit;

+ (CommonNetworkOutput*)updateUserPhoto:(NSString *)baseURL
                                  appId:(NSString *)appId
                                 userId:(NSString *)userId
                                   data:(NSData*)data;

+ (CommonNetworkOutput*)deleteUserPhoto:(NSString *)baseURL
                                  appId:(NSString *)appId
                                 userId:(NSString *)userId
                            userPhotoId:(NSString *)userPhotoId
                                  usage:(int)usage;

@end
