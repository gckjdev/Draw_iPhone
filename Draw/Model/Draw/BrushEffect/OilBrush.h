//
//  OilBrush.h
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface OilBrush : NSObject<BrushEffectProtocol>

+ (OilBrush*)sharedBrush;

@end
