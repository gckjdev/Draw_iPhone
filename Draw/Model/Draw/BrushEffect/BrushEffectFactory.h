//
//  BrushEffectFactory.h
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"
#import "ItemType.h"

@interface BrushEffectFactory : NSObject

+ (BrushEffectFactory*)sharedInstance;

- (id<BrushEffectProtocol>)brush:(ItemType)brushType;

@end
