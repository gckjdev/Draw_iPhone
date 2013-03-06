//
//  GameItemService.m
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import "GameItemService.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "NSDate+TKCategory.h"
#import "PBGameItemUtils.h"

#define ITEMS_FILE @"shop_item.pb"
#define BUNDLE_PATH @"shop_item.pb"
#define ITEMS_FILE_VERSION @"1.0"


@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)getItemsList:(GetItemsListResultHandler)handler
{
    //load data
    PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION] autorelease];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
        handler(YES, itemsList);
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        handler(NO, nil);
    }];
}

- (void)getItemsListWithType:(int)type
               resultHandler:(GetItemsListResultHandler)handler
{
    //load data
    PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION] autorelease];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type = %d",type];
        NSArray *array = [itemsList filteredArrayUsingPredicate:predicate];
        handler(YES, array);
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        handler(NO, nil);
    }];
}

- (void)getPromotingItemsList:(GetItemsListResultHandler)handler
{
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION] autorelease];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
        handler(YES, [bself promotingItemListFrom:itemsList]);
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        handler(NO, nil);
    }];
}

- (NSArray *)promotingItemListFrom:(NSArray *)itemList
{
    NSMutableArray *arr = [NSMutableArray array];
    for (PBGameItem *item in itemList) {
        if ([item isPromoting]) {
            [arr addObject:item];
        }
    }
    
    return arr;
}

@end
