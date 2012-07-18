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

ItemService *_staticItemService = nil;

@implementation ItemService

+ (ItemService *)defaultService
{
    if (_staticItemService == nil) {
        _staticItemService = [[ItemService alloc] init];
    }
    return _staticItemService;
}



- (void)receiveItem:(ItemType)type
{
    int awardAmount = [ItemManager awardAmountByItem:type];
    int awardExp = [ItemManager awardExpByItem:type];
    PPDebug(@"<receiveItem> type=%d, awardAmount=%d, exp=%d",
            type, awardAmount, awardExp);

    [[AccountService defaultService] awardAccount:awardAmount source:AwardCoinType];
    [[LevelService defaultService] awardExp:awardExp delegate:nil];
}

@end
