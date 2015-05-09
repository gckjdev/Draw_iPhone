//
//  NewPencilBrush.h
//  Draw
//
//  Created by HuangCharlie on 5/9/15.
//
//

#import <Foundation/Foundation.h>
#import "BrushEffectProtocol.h"

@interface NewPencilBrush : NSObject<BrushEffectProtocol>

+ (NewPencilBrush*)sharedBrush;

@end
