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

#import "ItemType.h"

#define ITEMS_FILE @"shop_item.pb"
#define BUNDLE_PATH @"shop_item.pb"
#define ITEMS_FILE_VERSION @"1.0"


@interface GameItemService()
@property (retain, nonatomic) NSArray *itemList;

@end

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    [_itemList release];
    [super dealloc];
}

- (void)getItemsList:(GetItemsListResultHandler)handler
{
    __block typeof(self) bself = self;    // when use "self" in block, must done like this

    //load data
    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        if (handler != NULL) {
            handler(YES, [bself itemsListFromFile:smartData.dataFilePath]);
        }
        [smartData release];
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        if (handler != NULL) {
            handler(YES, [bself itemsListFromFile:smartData.dataFilePath]);
        }
        [smartData release];
    }];
}

- (NSArray *)itemsListFromFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
    
    return itemsList;
}

- (void)updateItemListWithType:(int)type
                       handler:(GetItemsListResultHandler)handler
{
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [self getItemsList:^(BOOL success, NSArray *itemsList) {
        bself.itemList = itemsList;
        [bself getItemsListWithType:type resultHandler:^(BOOL success, NSArray *itemsList) {
            if (handler != NULL) {
                handler(success, itemsList);
            }
        }];
    }];
}

- (void)updatePromotingItemsList:(GetItemsListResultHandler)handler
{
    __block typeof(self) bself = self;    // when use "self" in block, must done like this
    [self getItemsList:^(BOOL success, NSArray *itemsList) {
        bself.itemList = itemsList;
        [bself getPromotingItemsList:^(BOOL success, NSArray *itemsList) {
            if (handler != NULL) {
                handler(success, itemsList);
            }
        }];
    }];
}


- (void)getItemsListWithType:(int)type
               resultHandler:(GetItemsListResultHandler)handler
{
//    //load data
//    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION];
//    
//    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
//        PPDebug(@"checkUpdateAndDownload successfully");
//        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
//        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.type = %d",type];
//        NSArray *array = [itemsList filteredArrayUsingPredicate:predicate];
//        if (handler != NULL) {
//            handler(YES, array);
//        }
//        [smartData release];
//    } failureBlock:^(NSError *error) {
//        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
//        if (handler != NULL) {
//            handler(NO, nil);
//        }
//        [smartData release];
//    }];
    
    NSMutableArray *array = [NSMutableArray array];
    for (PBGameItem *item in _itemList) {
        if (item.type == type) {
            [array addObject:item];
        }
    }
    
    if (handler != NULL) {
        handler(YES, array);
    }
}

- (void)getPromotingItemsList:(GetItemsListResultHandler)handler
{
//    __block typeof(self) bself = self;    // when use "self" in block, must done like this
//    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION];
//    
//    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
//        PPDebug(@"checkUpdateAndDownload successfully");
//        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
//        NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
//        if (handler != NULL) {
//            handler(YES, [bself promotingItemListFrom:itemsList]);
//        }
//        [smartData release];
//    } failureBlock:^(NSError *error) {
//        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
//        if (handler != NULL) {
//            handler(NO, nil);
//        }
//        [smartData release];
//    }];    
    if (handler != NULL) {
        handler(YES, [self promotingItemListFrom:_itemList]);
    }
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



//************************************************************
+ (PBItemPriceInfo *)currency:(PBGameCurrency)currency
                    price:(int)price
{
    PBItemPriceInfo_Builder *priceInfoBuilder = [[PBItemPriceInfo_Builder alloc] init];
    [priceInfoBuilder setCurrency:currency];
    [priceInfoBuilder setPrice:price];
    PBItemPriceInfo *priceInfo = [priceInfoBuilder build];
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
    
    for (int index = 0 ; index < 13; index ++) {
        PBGameItem_Builder *itemBuilder = [[PBGameItem_Builder alloc] init];
        
        //移除广告
        if (index == 0) {
            [itemBuilder setItemId:ItemTypeRemoveAd];
            [itemBuilder setName:@"kRemoveAd"];
            [itemBuilder setDesc:@"kRemoveAdDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"clean_ad@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"com.orange.draw.removead"];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:40];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //锦囊
        else if (index == 1){
            [itemBuilder setItemId:ItemTypeTips];
            [itemBuilder setName:@"kTips"];
            [itemBuilder setDesc:@"kTipsDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeMultiple];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"tipbag@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:40];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //颜色
        else if (index == 2){
            [itemBuilder setItemId:ItemTypeColor];
            [itemBuilder setName:@"kBuyColor"];
            [itemBuilder setDesc:@"kBuyColor"];
            [itemBuilder setSalesType:PBGameItemSalesTypeMultiple];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"print_oil@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:100];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //番茄
        else if (index == 3) {
            [itemBuilder setItemId:ItemTypeTomato];
            [itemBuilder setName:@"kTomato"];
            [itemBuilder setDesc:@"kTomatoDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeMultiple];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"tomato@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:40];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:80 startDate:startDate expireDate:startDate + 7 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }
        
        //鲜花
        else if (index == 4){
            [itemBuilder setItemId:ItemTypeFlower];
            [itemBuilder setName:@"kFlower"];
            [itemBuilder setDesc:@"kFlowerDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeMultiple];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"flower@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:40];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }
        
        //调色板
        else if (index == 5){
            [itemBuilder setItemId:PaletteItem];
            [itemBuilder setName:@"kPaletteItem"];
            [itemBuilder setDesc:@"kPaletteItemDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_palette@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:4000];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }
        
        //作品播放器
        else if (index == 6){
            [itemBuilder setItemId:PaintPlayerItem];
            [itemBuilder setName:@"kPaintPlayerItem"];
            [itemBuilder setDesc:@"kPaintPlayerItemDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_paint_player@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self discount:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
        }

        //吸管
        else if (index == 7){
            [itemBuilder setItemId:ColorStrawItem];
            [itemBuilder setName:@"kStraw"];
            [itemBuilder setDesc:@"kStrawDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_straw@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:600];
            [itemBuilder setPriceInfo:priceInfo];
            
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //透明度
        else if (index == 8){
            [itemBuilder setItemId:ColorAlphaItem];
            [itemBuilder setName:@"kColorAlphaItem"];
            [itemBuilder setDesc:@"kColorAlphaItemDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:4000];
            [itemBuilder setPriceInfo:priceInfo];
            
            //[itemBuilder setPromotionInfo:nil];
        }

        
        //毛笔
        else if (index == 9){
            [itemBuilder setItemId:Pen];
            [itemBuilder setName:@"kPen"];
            [itemBuilder setDesc:@"kBrushPenDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"brush_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];

            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:6];
            [itemBuilder setPriceInfo:priceInfo];
            
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //雪糕笔
        else if (index == 10){
            [itemBuilder setItemId:IcePen];
            [itemBuilder setName:@"kIcePen"];
            [itemBuilder setDesc:@"kIcePenDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"cones_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:6];
            [itemBuilder setPriceInfo:priceInfo];
            
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //鹅毛笔
        else if (index == 11){
            [itemBuilder setItemId:Quill];
            [itemBuilder setName:@"kQuill"];
            [itemBuilder setDesc:@"kQuillDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"quill_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            

            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:6];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
        }
        
        //麦克笔
        else if (index == 12){
            [itemBuilder setItemId:WaterPen];
            [itemBuilder setName:@"kWaterPen"];
            [itemBuilder setDesc:@"kWaterPenDescription"];
            [itemBuilder setSalesType:PBGameItemSalesTypeOneOff];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"mike_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:6];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
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
