//
//  TransactionReceipt.h
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TransactionReceipt : NSManagedObject

@property (nonatomic, retain) NSString * transactionId;
@property (nonatomic, retain) NSString * productId;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * transactionReceipt;
@property (nonatomic, retain) NSNumber * verifyStatus;
@property (nonatomic, retain) NSDate * verifyDate;
@property (nonatomic, retain) NSNumber * createDate;
@property (nonatomic, retain) NSNumber * isVerified;
@property (nonatomic, retain) NSDate * lastRetryDate;
@property (nonatomic, retain) NSNumber * retryTimes;

@end
