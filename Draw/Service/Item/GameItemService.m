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
@property (retain, nonatomic) NSArray *itemsList;

@end

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    [_itemsList release];
    [super dealloc];
}

- (void)syncData:(GetItemsListResultHandler)handler
{
    __block typeof(self) bself = self;
    
    //load data
    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        bself.itemsList = [bself itemsListFromFile:smartData.dataFilePath];
        if (handler != NULL) {
            handler(YES, bself.itemsList);
        }
        [smartData release];
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        bself.itemsList = [bself itemsListFromFile:smartData.dataFilePath];
        if (handler != NULL) {
            handler(NO, bself.itemsList);
        }
        [smartData release];
    }];
}

- (NSArray *)getItemsList
{
    return self.itemsList;
}

- (NSArray *)getItemsListWithType:(int)type
{
    NSMutableArray *array = [NSMutableArray array];
    for (PBGameItem *item in _itemsList) {
        if (item.type == type) {
            [array addObject:item];
        }
    }
    
    return array;
}

- (NSArray *)getPromotingItemsList
{
    NSMutableArray *array = [NSMutableArray array];
    for (PBGameItem *item in _itemsList) {
        if ([item isPromoting]) {
            [array addObject:item];
        }
    }
    
    return array;
}

- (NSArray *)itemsListFromFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
    
    return itemsList;
}

- (PBGameItem *)itemWithItemId:(int)itemId
{
    for (PBGameItem *item in _itemsList) {
        if (item.itemId == itemId) {
            return item;
        }
    }
    
    return nil;
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

+ (PBPromotionInfo *)price:(int)price
                 startDate:(int)startDate
                expireDate:(int)expireDate
{
    PBPromotionInfo_Builder *promotionInfoBuilder = [[PBPromotionInfo_Builder alloc] init];
    [promotionInfoBuilder setPrice:price];
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
    
    for (int index = 0 ; index < 18; index ++) {
        PBGameItem_Builder *itemBuilder = [[PBGameItem_Builder alloc] init];
        
        //移除广告
        if (index == 0) {
            [itemBuilder setItemId:ItemTypeRemoveAd];
            [itemBuilder setName:@"kRemoveAd"];
            [itemBuilder setDesc:@"kRemoveAdDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];

            [itemBuilder setImage:URL_ITEM_IMAGE(@"clean_ad@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:@"com.orange.draw.removead"];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:40];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //虚线笔
        if (index == 1) {
            [itemBuilder setItemId:DottedLinePen];
            [itemBuilder setName:@"kDottedLinePen"];
            [itemBuilder setDesc:@"kDottedLinePenDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            
            [itemBuilder setImage:URL_ITEM_IMAGE(@"dotted_line_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            [itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:1000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //虚线笔
        if (index == 1) {
            [itemBuilder setItemId:DottedLinePen];
            [itemBuilder setName:@"kDottedLinePen"];
            [itemBuilder setDesc:@"kDottedLinePenDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            
            [itemBuilder setImage:URL_ITEM_IMAGE(@"dotted_line_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            [itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:1000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //麦克笔
        else if (index == 2){
            [itemBuilder setItemId:WaterPen];
            [itemBuilder setName:@"kWaterPen"];
            [itemBuilder setDesc:@"kWaterPenDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"mike_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:1000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //平滑笔
        else if (index == 3){
            [itemBuilder setItemId:SmoothPen];
            [itemBuilder setName:@"kSmoothPen"];
            [itemBuilder setDesc:@"kSmoothPenDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"smooth_pen@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:2];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //横版画布
        else if (index == 4){
            [itemBuilder setItemId:TransverseCanvas];
            [itemBuilder setName:@"kTransverseCanvas"];
            [itemBuilder setDesc:@"kTransverseCanvasDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"transverse_canva@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:1000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //竖版画布
        else if (index == 5){
            [itemBuilder setItemId:VerticalCanvas];
            [itemBuilder setName:@"kVerticalCanvas"];
            [itemBuilder setDesc:@"kVerticalCanvasDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"vertical_canvas@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:1000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //正方形画布(大)
        else if (index == 6){
            [itemBuilder setItemId:SquareCanvasLarge];
            [itemBuilder setName:@"kSquareCanvasLarge"];
            [itemBuilder setDesc:@"kSquareCanvasLargeDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"square_canvas_large@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:2];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //横版画布(大)
        else if (index == 7){
            [itemBuilder setItemId:TransverseCanvasLarge];
            [itemBuilder setName:@"kTransverseCanvasLarge"];
            [itemBuilder setDesc:@"kTransverseCanvasLargeDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"transverse_canvas_large@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:2];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //竖版画布(大)
        else if (index == 7){
            [itemBuilder setItemId:VerticalCanvasLarge];
            [itemBuilder setName:@"kVerticalCanvasLarge"];
            [itemBuilder setDesc:@"kVerticalCanvasLargeDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"vertical_canvas_large@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:2];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //纹理背景
        else if (index == 8){
            [itemBuilder setItemId:VeinsBackground];
            [itemBuilder setName:@"kVeinsBackground"];
            [itemBuilder setDesc:@"kVeinsBackgroundDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"veins_background@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:4];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //吸管
        else if (index == 9){
            [itemBuilder setItemId:ColorStrawItem];
            [itemBuilder setName:@"kStraw"];
            [itemBuilder setDesc:@"kStrawDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_straw@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:600];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //作品播放器
        else if (index == 10){
            [itemBuilder setItemId:PaintPlayerItem];
            [itemBuilder setName:@"kPaintPlayerItem"];
            [itemBuilder setDesc:@"kPaintPlayerItemDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_paint_player@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self price:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //调色板
        else if (index == 11){
            [itemBuilder setItemId:PaletteItem];
            [itemBuilder setName:@"kPaletteItem"];
            [itemBuilder setDesc:@"kPaletteItemDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_palette@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:2000];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self price:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //基本形状
        else if (index == 12){
            [itemBuilder setItemId:BasicShape];
            [itemBuilder setName:@"kBasicShape"];
            [itemBuilder setDesc:@"kBasicShapeDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"Basic_Shape@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:5];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //透明度
        else if (index == 13){
            [itemBuilder setItemId:ColorAlphaItem];
            [itemBuilder setName:@"kColorAlphaItem"];
            [itemBuilder setDesc:@"kColorAlphaItemDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:4000];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //钱袋
        else if (index == 14){
            [itemBuilder setItemId:PurseItem];
            [itemBuilder setName:@"kPurseItem"];
            [itemBuilder setDesc:@"kPurseItemDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"purse_item@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeTool];
            //[itemBuilder setAppleProductId:nil];
            
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyIngot price:10];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //鲜花
        else if (index == 15){
            [itemBuilder setItemId:ItemTypeFlower];
            [itemBuilder setName:@"kFlower"];
            [itemBuilder setDesc:@"kFlowerDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeAmountConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"flower@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:20];
            [itemBuilder setPriceInfo:priceInfo];
            
            int startDate = (int)[[NSDate date] timeIntervalSince1970];
            PBPromotionInfo *promotionInfo = [self price:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
            [itemBuilder setPromotionInfo:promotionInfo];
            
            [itemBuilder setDefaultSaleCount:10];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //锦囊
        else if (index == 16){
            [itemBuilder setItemId:ItemTypeTips];
            [itemBuilder setName:@"kTips"];
            [itemBuilder setDesc:@"kTipsDescription"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeAmountConsumable];

            [itemBuilder setImage:URL_ITEM_IMAGE(@"tipbag@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:20];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            [itemBuilder setDefaultSaleCount:10];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
        }
        
        //颜色
        else if (index == 17){
            [itemBuilder setItemId:ItemTypeColor];
            [itemBuilder setName:@"kBuyColor"];
            [itemBuilder setDesc:@"kBuyColor"];
            [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
            [itemBuilder setImage:URL_ITEM_IMAGE(@"print_oil@2x.png")];
            //[itemBuilder setDemoImage:nil];
            [itemBuilder setType:PBDrawItemTypeNomal];
            //[itemBuilder setAppleProductId:nil];
            
            PBItemPriceInfo *priceInfo = [self currency:PBGameCurrencyCoin price:100];
            [itemBuilder setPriceInfo:priceInfo];
            //[itemBuilder setPromotionInfo:nil];
            
            //[itemBuilder setDefaultSaleCount:1];
            //[itemBuilder setUsageLifeUnit:nil];
            //[itemBuilder setUsageLife:0];
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
