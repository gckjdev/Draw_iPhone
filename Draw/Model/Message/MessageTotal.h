//
//  MessageTotal.h
//  Draw
//
//  Created by haodong qiu on 12年6月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MessageTotal : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * friendUserId;
@property (nonatomic, retain) NSString * friendNickName;
@property (nonatomic, retain) NSString * friendAvatar;
@property (nonatomic, retain) NSString * latestFrom;
@property (nonatomic, retain) NSString * latestTo;
@property (nonatomic, retain) NSData * latestDrawData;
@property (nonatomic, retain) NSString * latestText;
@property (nonatomic, retain) NSDate * latestCreateDate;
@property (nonatomic, retain) NSNumber * totalNewMessage;
@property (nonatomic, retain) NSNumber * totalMessage;

@end
