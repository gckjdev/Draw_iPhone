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


//************************************************************
+ (PBPriceInfo *)currency:(PBGameCurrency)currency
                    price:(int)price
{
    PBPriceInfo_Builder *priceInfoBuilder = [[PBPriceInfo_Builder alloc] init];
    [priceInfoBuilder setCurrency:currency];
    [priceInfoBuilder setPrice:price];
    PBPriceInfo *priceInfo = [priceInfoBuilder build];
    [priceInfoBuilder release];
    return priceInfo;
}

+ (PBPromotionInfo *)discount:(int)discount
                    startDate:(int)startDate
                   expireDate:(int)expireDate
{
    PBPromotionInfo_Builder *promotionInfoBuilder = [[PBPromotionInfo_Builder alloc] init];
    [promotionInfoBuilder setDiscount:discount];
    [promotionInfoBuilder setStartDate:startDate];
    [promotionInfoBuilder setExpireDate:expireDate];
    PBPromotionInfo *promotionInfo = [promotionInfoBuilder build];
    [promotionInfoBuilder release];
    return promotionInfo;
}


#define URL_ITEM_IMAGE(name) [NSString stringWithFormat:@"http://58.215.160.100:8080/app_res/test/%@", name]

+ (void)createTestDataFile
{    
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int index = 0 ; index < 8; index ++) {
        PBGameItem_Builder *itemBuilder = [[PBGameItem_Builder alloc] init];
        
        //鲜花
        if (index == 0){
            [itemBuilder setItemId:0];
            [itemBuilder setName:@"kFlower"];
            [itemBuilder setDesc:@"kFlowerDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"flower@2x.png")];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"testIapId_000"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:400];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:70 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }
        
        //番茄
        else if (index == 1) {
            [itemBuilder setItemId:1];
            [itemBuilder setName:@"kTomato"];
            [itemBuilder setDesc:@"kTomatoDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"tomato@2x.png")];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"testIapId_001"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:200];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:80 startDate:startDate expireDate:startDate + 7 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }
        
        //移除广告
        else if (index == 2) {
            [itemBuilder setItemId:2];
            [itemBuilder setName:@"kRemoveAd"];
            [itemBuilder setDesc:@"kRemoveAdDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"clean_ad@2x.png")];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"testIapId_002"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:200];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        //锦囊
        else if (index == 3){
            [itemBuilder setItemId:3];
            [itemBuilder setName:@"kTips"];
            [itemBuilder setDesc:@"kTipsDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"tipbag@2x.png")];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"testIapId_003"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:5];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        //毛笔
        else if (index == 4){
            [itemBuilder setItemId:4];
            [itemBuilder setName:@"kPen"];
            [itemBuilder setDesc:@"kBrushPenDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"brush_pen@2x.png")];
            [itemBuilder setType:PBDrawItemTypeTool];
            [itemBuilder setAppleProductId:@"testIapId_004"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        //雪糕笔
        else if (index == 5){
            [itemBuilder setItemId:5];
            [itemBuilder setName:@"kIcePen"];
            [itemBuilder setDesc:@"kIcePenDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"cones_pen@2x.png")];
            [itemBuilder setType:PBDrawItemTypeTool];
            [itemBuilder setAppleProductId:@"testIapId_005"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        //毛笔
        else if (index == 6){
            [itemBuilder setItemId:6];
            [itemBuilder setName:@"kQuill"];
            [itemBuilder setDesc:@"kQuillDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"quill_pen@2x.png")];
            [itemBuilder setType:PBDrawItemTypeTool];
            [itemBuilder setAppleProductId:@"testIapId_006"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        //麦克笔
        else if (index == 7){
            [itemBuilder setItemId:7];
            [itemBuilder setName:@"kWaterPen"];
            [itemBuilder setDesc:@"kWaterPenDescription"];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"mike_pen@2x.png")];
            [itemBuilder setType:PBDrawItemTypeTool];
            [itemBuilder setAppleProductId:@"testIapId_007"];
            
            PBPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
        }
        
        
        PBGameItem *item = [itemBuilder build];
        [itemBuilder release];
        [mutableArray addObject:item];
    }

    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = @"/Users/gckj/shopItem/shop_item.pb";
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


@end
