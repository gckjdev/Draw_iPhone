//
//  ItemUseRecorder.h
//  Draw
//
//  Created by 王 小涛 on 13-6-25.
//
//

#import <Foundation/Foundation.h>
#import "ItemType.h"

@interface ItemUseRecorder : NSObject

+ (void)increaseItemTimes:(ItemType)itemType onOpus:(NSString *)opusId;
+ (int)itemTimes:(ItemType)itemType onOpus:(NSString *)opusId;

@end
