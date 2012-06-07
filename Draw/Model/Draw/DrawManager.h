//
//  DrawManager.h
//  Draw
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Draw;
@class PBDraw;
@interface DrawManager : NSObject


+ (Draw *)parseFromPBdraw:(PBDraw *)pbDraw;
@end
