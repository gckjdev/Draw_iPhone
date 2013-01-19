//
//  PenFactory.h
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import <Foundation/Foundation.h>
#import "PenEffectProtocol.h"
#import "ItemType.h"

@interface PenFactory : NSObject

+ (id<PenEffectProtocol>)getPen:(ItemType)penType;

@end
