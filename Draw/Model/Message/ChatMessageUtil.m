//
//  ChatMessageUtil.m
//  Draw
//
//  Created by haodong qiu on 12年6月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatMessageUtil.h"

@implementation ChatMessageUtil

//压缩
+ (NSData *)archiveDataFromDrawActionList:(NSArray *)aDrawActionList
{    
    NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:aDrawActionList];
    return reData;
}

//解压
+ (NSArray *)unarchiveDataToDrawActionList:(NSData *)aData
{
    NSData* temp = [NSKeyedUnarchiver unarchiveObjectWithData:aData];
    NSArray* drawDataList = (NSArray*)temp;
    return drawDataList;
}


@end
