//
//  FilledCalligraphyBrush.h
//  Draw
//
//  Created by 黄毅超 on 14-10-11.
//
//

#import <Foundation/Foundation.h>
#import <BrushEffectFactory.h>

@interface FilledCalligraphyBrush : NSObject<BrushEffectProtocol>

+ (FilledCalligraphyBrush*)sharedBrush;

@end
