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

#define ITEMS_FILE @"items.pb"
#define BUNDLE_PATH @"items.pb"
#define ITEMS_FILE_VERSION @"1.0"

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    [super dealloc];
}

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
    //load data
    PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION] autorelease];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
        handler(YES, [self promotingItemListFrom:itemsList]);
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        handler(NO, nil);
    }];
}

- (NSArray *)promotingItemListFrom:(NSArray *)itemList
{
    NSMutableArray *arr = [NSMutableArray array];
    for (PBGameItem *item in itemList) {
        if ([self isItemPromoting:item]) {
            [arr addObject:item];
        }
    }
    
    return arr;
}

- (BOOL)isItemPromoting:(PBGameItem *)item
{
    if (![item hasPromotionInfo]) {
        return NO;
    }
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:item.promotionInfo.startDate];
    NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:item.promotionInfo.expireDate];
    
    NSDate *earlierDate = [startDate earlierDate:[NSDate date]];
    NSDate *laterDate = [expireDate earlierDate:[NSDate date]];
    
    if ([earlierDate isEqualToDate:startDate] && [laterDate isEqualToDate:expireDate]) {
        return YES;
    }
    
    return NO;
}


@end
