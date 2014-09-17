//
//  PencilBrush.h
//  Draw
//
//  Created by 黄毅超 on 14-9-16.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface PencilBrush : NSObject <BrushEffectProtocol>

+ (PencilBrush*)sharedBrush;

@end
