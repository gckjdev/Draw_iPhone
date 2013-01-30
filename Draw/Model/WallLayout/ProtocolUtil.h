//
//  ProtocolUtil.h
//  Draw
//
//  Created by 王 小涛 on 13-1-29.
//
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"

@interface ProtocolUtil : NSObject
+ (PBRect *)pbRectWithX:(int)x y:(int)y width:(int)width height:(int)height;

+ (PBLayout *)createTestData1;
+ (PBLayout *)createTestData;

+ (void)createFramesTestData;

@end
