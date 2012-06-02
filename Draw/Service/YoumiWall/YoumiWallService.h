//
//  YoumiWallService.h
//  Draw
//
//  Created by  on 12-6-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMiWall.h"

@interface YoumiWallService : NSObject
{
    YouMiWall *_wall;
}

+ (YoumiWallService *)defaultService;
- (void)queryPoints;
- (NSArray*)getOrderList;

@end
