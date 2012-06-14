//
//  ChatMessageUtil.h
//  Draw
//
//  Created by haodong qiu on 12年6月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessageUtil : NSObject

//压缩
+ (NSData *)archiveDataFromDrawActionList:(NSArray *)aDrawActionList;

//解压
+ (NSArray *)unarchiveDataToDrawActionList:(NSData *)aData;

@end
