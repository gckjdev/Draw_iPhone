//
//  LayoutManager.h
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"

@interface LayoutManager : NSObject

+ (LayoutManager *)sharedLayoutManager;

+ (PBLayout *)createTestData;

@end
