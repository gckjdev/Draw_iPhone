//
//  FrameManager.h
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"

@interface FrameManager : NSObject

+ (FrameManager *)sharedFrameManager;

- (PBFrame *)frameWithFrameId:(int)frameId;
- (NSArray *)frames;
- (NSArray *)framesOfType:(int)type;

@end
