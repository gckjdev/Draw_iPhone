//
//  DrawManager.m
//  Draw
//
//  Created by  on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawManager.h"
#import "Paint.h"
#import "Draw.h"
#import "DrawAction.h"
#import "GameBasic.pb.h"
@implementation DrawManager


+ (NSMutableArray *)parseFromPBDrawActionList:(NSArray *)pbDrawActions
{
    if ([pbDrawActions count] == 0) {
        return nil;
    }
    NSMutableArray *retArray = [NSMutableArray array];
    for (PBDrawAction *action in pbDrawActions) {
        DrawAction *drawAction = [DrawAction drawActionWithPBDrawAction:action];
        [retArray addObject:drawAction];
    }
    return retArray;
}

+ (Draw *)parseFromPBdraw:(PBDraw *)pbDraw
{
    if (pbDraw == nil) {
        return nil;
    }    
    return [[[Draw alloc] initWithPBDraw:pbDraw] autorelease];
}
@end
