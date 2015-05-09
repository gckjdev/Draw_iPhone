//
//  NewCrayonBrush.h
//  Draw
//
//  Created by HuangCharlie on 5/9/15.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface NewCrayonBrush : NSObject<BrushEffectProtocol>

+ (NewCrayonBrush*)sharedBrush;

@end
