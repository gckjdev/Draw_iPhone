//
//  ItemService.m
//  Draw
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ItemService.h"
#import "AccountService.h"

ItemService *_staticItemService = nil;

@implementation ItemService

+ (ItemService *)defaultService
{
    if (_staticItemService == nil) {
        _staticItemService = [[ItemService alloc] init];
    }
    return _staticItemService;
}



- (void)useItem:(ItemType)type 
   toTargetFeed:(Feed *)feed 
       delegate:(id<ItemServiceDelegate>)delegate
{
    
//    NSString *userID feedId createUid 
    
    //comsum item
    
}

@end
