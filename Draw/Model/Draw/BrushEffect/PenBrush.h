//
//  PenBrush.h
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface PenBrush : NSObject<BrushEffectProtocol>

+ (PenBrush*)sharedBrush;

@end