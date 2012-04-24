//
//  TransactionReceiptManager.m
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TransactionReceiptManager.h"
#import "CoreDataUtil.h"
#import "PPDebug.h"

@implementation TransactionReceiptManager

static TransactionReceiptManager *_defaultManager;

+ (TransactionReceiptManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[TransactionReceiptManager alloc] init];
    }
    
    return _defaultManager;
}

- (NSArray*)findAllUnverfiedReceipts
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllUnverfiedReceipts"];
}

- (TransactionReceipt*)findReceiptById:(NSString*)transactionId
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    return (TransactionReceipt*)[dataManager execute:@"findReceiptById" 
                                              forKey:@"TRANSACTION_ID" 
                                               value:transactionId];    
}

- (void)createReceipt:(NSString*)transactionId
            productId:(NSString*)productId
               amount:(int)amount
   transactionReceipt:(NSString*)transactionReceipt
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    TransactionReceipt* receipt = [dataManager insert:@"TransactionReceipt"];
    
    [receipt setAmount:[NSNumber numberWithInt:amount]];
    [receipt setProductId:productId];
    [receipt setTransactionReceipt:transactionReceipt];
    [receipt setTransactionId:transactionId];
    [receipt setVerifyDate:[NSDate date]];
    [receipt setVerifyStatus:[NSNumber numberWithInt:-1]];
    [receipt setIsVerified:[NSNumber numberWithInt:0]];
    
    [dataManager save];    
    return;
}

- (void)verifyUnknown:(TransactionReceipt*)receipt
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    [receipt setIsVerified:[NSNumber numberWithInt:0]];
    [receipt setLastRetryDate:[NSDate date]];
    [receipt setRetryTimes:[NSNumber numberWithInt:[[receipt retryTimes] intValue]+1]];
    PPDebug(@"<verifyUnknown> receipt = %@", [receipt description]);    
    [dataManager save];
}


- (void)verifyFailure:(TransactionReceipt*)receipt errorCode:(int)errorCode
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    [receipt setIsVerified:[NSNumber numberWithInt:1]];    
    [receipt setLastRetryDate:[NSDate date]];
    [receipt setRetryTimes:[NSNumber numberWithInt:[[receipt retryTimes] intValue]+1]];
    [receipt setVerifyStatus:[NSNumber numberWithInt:errorCode]];
    PPDebug(@"<verifyFailure> receipt = %@", [receipt description]);
    [dataManager save];  
}

- (void)verifySuccess:(TransactionReceipt*)receipt
{
    CoreDataManager* dataManager = [CoreDataManager defaultManager];
    [receipt setIsVerified:[NSNumber numberWithInt:1]];    
    [receipt setLastRetryDate:[NSDate date]];
    [receipt setRetryTimes:[NSNumber numberWithInt:[[receipt retryTimes] intValue]+1]];
    [receipt setVerifyStatus:[NSNumber numberWithInt:0]];
    PPDebug(@"<verifySuccess> receipt = %@", [receipt description]);
    [dataManager save];    
}

@end
