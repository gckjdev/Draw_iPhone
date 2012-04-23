//
//  TransactionReceiptManager.h
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionReceipt.h"

@interface TransactionReceiptManager : NSObject

- (NSArray*)findAllUnverfiedReceipts;
- (void)createReceipt:(NSString*)transactionId
            productId:(NSString*)productId
               amount:(int)amount
   transactionReceipt:(NSString*)transactionReceipt;


+ (TransactionReceiptManager*)defaultManager;
- (void)verifyUnknown:(TransactionReceipt*)receipt;
- (void)verifySuccess:(TransactionReceipt*)receipt;
- (void)verifyFailure:(TransactionReceipt*)receipt errorCode:(int)errorCode;

@end
