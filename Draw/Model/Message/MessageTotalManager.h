//
//  MessageTotalManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

//(NSString *)userId;
//(NSString *)friendUserId;
//(NSString *)friendNickName;
//(NSString *)friendAvatar;
//(NSString *)latestFrom;
//(NSString *)latestTo;
//(NSData *)latestDrawData;
//(NSString *)latestText;
//(NSDate *)latestCreateDate;
//(NSNumber *)totalNewMessage;
//(NSNumber *)totalMessage;

@interface MessageTotalManager : NSObject

+ (MessageTotalManager *)defaultManager;

- (BOOL)createMessageTotalWithUserId:(NSString *)userId 
                        friendUserId:(NSString *)friendUserId 
                      friendNickName:(NSString *)friendNickName 
                        friendAvatar:(NSString *)friendAvatar 
                          latestFrom:(NSString *)latestFrom 
                            latestTo:(NSString *)latestTo 
                      latestDrawData:(NSData *)latestDrawData 
                          latestText:(NSString *)latestText 
                    latestCreateDate:(NSDate *)latestCreateDate 
                     totalNewMessage:(NSNumber *)totalNewMessage 
                        totalMessage:(NSNumber *)totalMessage;

- (BOOL)deleteMessageTotal:(NSString *)friendUserId;

@end
