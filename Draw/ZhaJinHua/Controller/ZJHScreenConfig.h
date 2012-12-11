//
//  ZJHScreenConfig.h
//  Draw
//
//  Created by 王 小涛 on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "ZJHConstance.h"



@interface ZJHScreenConfig : NSObject

+ (CGPoint)getActionMessageViewOriginByPosition:(UserPosition)position;
+ (CGPoint)getChatMessageViewOriginByPosition:(UserPosition)position;

@end
