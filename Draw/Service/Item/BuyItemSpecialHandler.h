//
//  BuyItemSpecialHandler.h
//  Draw
//
//  Created by 王 小涛 on 13-4-11.
//
//

#import <Foundation/Foundation.h>

@interface BuyItemSpecialHandler : NSObject

+ (void)buySpecialHandle:(int)itemId
                   count:(int)count;

+ (void)giveSpecialHandle:(int)itemId
                    count:(int)count
                 toUserId:(NSString *)toUserId;
@end
