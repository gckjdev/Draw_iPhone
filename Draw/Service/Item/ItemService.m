//
//  ItemService.m
//  Draw
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemService.h"
#import "AccountService.h"
#import "ItemManager.h"
#import "LevelService.h"
#import "PPDebug.h"
#import "DrawGameService.h"
#import "GameConstants.h"
#import "FeedService.h"

ItemService *_staticItemService = nil;

@implementation ItemService

+ (ItemService *)defaultService
{
    if (_staticItemService == nil) {
        _staticItemService = [[ItemService alloc] init];
    }
    return _staticItemService;
}


@end
