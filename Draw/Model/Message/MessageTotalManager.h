//
//  MessageTotalManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBMessageStat;
@interface MessageTotalManager : NSObject

+ (MessageTotalManager *)defaultManager;

- (BOOL)createMessageTotalWithUserId:(NSString *)userId 
                        friendUserId:(NSString *)friendUserId 
                      friendNickName:(NSString *)friendNickName 
                        friendAvatar:(NSString *)friendAvatar 
                        friendGender:(NSString *)friendGender
                          latestFrom:(NSString *)latestFrom 
                            latestTo:(NSString *)latestTo 
                      latestDrawData:(NSData *)latestDrawData 
                          latestText:(NSString *)latestText 
                    latestCreateDate:(NSDate *)latestCreateDate 
                     totalNewMessage:(NSNumber *)totalNewMessage 
                        totalMessage:(NSNumber *)totalMessage;

- (NSArray *)findAllMessageTotals;

- (BOOL)createByPBMessageStat:(PBMessageStat *)pbMessageStat;

- (BOOL)readNewMessageWithFriendUserId:(NSString *)friendUserId userId:(NSString *)userId;

@end
