//
//  FeatherBrush.h
//  Draw
//
//  Created by 黄毅超 on 14-9-18.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface FeatherBrush : NSObject<BrushEffectProtocol>

+ (FeatherBrush*)sharedBrush;

@end