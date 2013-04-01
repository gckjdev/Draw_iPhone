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
#import "GameItemManager.h"
#import "ItemType.h"
#import "BlockArray.h"

@interface GameItemService()
@property (retain, nonatomic) BlockArray *blockArray;

@end

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    [_blockArray releaseAllBlock];
    [_blockArray release];
    [super dealloc];
}

- (id)init
{
    if(self = [super init])
    {
        self.blockArray = [[[BlockArray alloc] init] autorelease];
    }
    
    return self;
}


- (void)syncData:(SyncItemsDataResultHandler)handler
{
    SyncItemsDataResultHandler tempHandler = (SyncItemsDataResultHandler)[_blockArray copyBlock:handler];

    
    //load data
    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:[GameItemManager shopItemsFileName] type:SMART_UPDATE_DATA_TYPE_PB bundlePath:[GameItemManager shopItemsFileBundlePath] initDataVersion:[GameItemManager shopItemsFileVersion]];
    
    __block typeof(self) bself = self;

    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        [bself updateItemsWithFile:dataFilePath];
        EXECUTE_BLOCK(tempHandler, YES);
        [bself.blockArray releaseBlock:tempHandler];
        [smartData release];
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        PPDebug(@"datafilepath = %@", smartData.dataFilePath);
        NSArray *itemsList = [bself itemsListFromFile:smartData.dataFilePath];
        [[GameItemManager defaultManager] setItemsList:itemsList];

        EXECUTE_BLOCK(tempHandler, NO);
        [bself.blockArray releaseBlock:tempHandler];

        [smartData release];
    }];
}

- (void)updateItemsWithFile:(NSString *)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
    [[GameItemManager defaultManager] setItemsList:itemsList];
}

- (NSArray *)itemsListFromFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *itemsList = [[PBGameItemList parseFromData:data] itemsList];
    
    return itemsList;
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

    PBGameItem_Builder *itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];

    // 鲜花
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
    PBPromotionInfo *promotionInfo = [self price:10 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
    [itemBuilder setPromotionInfo:promotionInfo];
    [itemBuilder setDefaultSaleCount:10];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    // 锦囊
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:ItemTypeTips];
    [itemBuilder setName:@"kTips"];
    [itemBuilder setDesc:@"kTipsDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeAmountConsumable];

    [itemBuilder setImage:URL_ITEM_IMAGE(@"tipbag@2x.png")];
    [itemBuilder setType:PBDrawItemTypeNomal];    
    priceInfo = [self currency:PBGameCurrencyCoin price:20];
    [itemBuilder setPriceInfo:priceInfo];
    [itemBuilder setDefaultSaleCount:10];
    [mutableArray addObject:[itemBuilder build]];


    // 购买颜色
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:ItemTypeColor];
    [itemBuilder setName:@"kBuyColor"];
    [itemBuilder setDesc:@"kBuyColor"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"print_oil@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeNomal];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyCoin price:100];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //移除广告
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:ItemTypeRemoveAd];
    [itemBuilder setName:@"kRemoveAd"];
    [itemBuilder setDesc:@"kRemoveAdDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];

    [itemBuilder setImage:URL_ITEM_IMAGE(@"clean_ad@2x.png")];
    [itemBuilder setType:PBDrawItemTypeNomal];
    [itemBuilder setAppleProductId:@"com.orange.draw.removead"];

    priceInfo = [self currency:PBGameCurrencyCoin price:400];
    [itemBuilder setPriceInfo:priceInfo];
    [mutableArray addObject:[itemBuilder build]];

    //透明度
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:ColorAlphaItem];
    [itemBuilder setName:@"kColorAlphaItem"];
    [itemBuilder setDesc:@"kColorAlphaItemDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];


    priceInfo = [self currency:PBGameCurrencyCoin price:4000];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];
    
    //作品播放器
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:PaintPlayerItem];
    [itemBuilder setName:@"kPaintPlayerItem"];
    [itemBuilder setDesc:@"kPaintPlayerItemDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_paint_player@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];
    
    priceInfo = [self currency:PBGameCurrencyCoin price:2000];
    [itemBuilder setPriceInfo:priceInfo];
    
    startDate = (int)[[NSDate date] timeIntervalSince1970];
    promotionInfo = [self price:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
    [itemBuilder setPromotionInfo:promotionInfo];
    
    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];
    
    //调色板
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:PaletteItem];
    [itemBuilder setName:@"kPaletteItem"];
    [itemBuilder setDesc:@"kPaletteItemDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_palette@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];
    
    
    priceInfo = [self currency:PBGameCurrencyCoin price:2000];
    [itemBuilder setPriceInfo:priceInfo];
    
    startDate = (int)[[NSDate date] timeIntervalSince1970];
    promotionInfo = [self price:80 startDate:startDate expireDate:startDate + 5 * 24 * 60 * 60];
    [itemBuilder setPromotionInfo:promotionInfo];
    
    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //吸管
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:ColorStrawItem];
    [itemBuilder setName:@"kStraw"];
    [itemBuilder setDesc:@"kStrawDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"shop_item_straw@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];
    
    priceInfo = [self currency:PBGameCurrencyCoin price:600];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];
    
    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //虚线笔
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:DottedLinePen];
    [itemBuilder setName:@"kDottedLinePen"];
    [itemBuilder setDesc:@"kDottedLinePenDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];

    [itemBuilder setImage:URL_ITEM_IMAGE(@"dotted_line_pen@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeNomal];
    [itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyCoin price:1000];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];


    //麦克笔
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:WaterPen];
    [itemBuilder setName:@"kWaterPen"];
    [itemBuilder setDesc:@"kWaterPenDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"mike_pen@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];
    priceInfo = [self currency:PBGameCurrencyCoin price:1000];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    // 平滑笔
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:SmoothPen];
    [itemBuilder setName:@"kSmoothPen"];
    [itemBuilder setDesc:@"kSmoothPenDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"smooth_pen@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyIngot price:2];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];


    //横版画布
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:TransverseCanvas];
    [itemBuilder setName:@"kTransverseCanvas"];
    [itemBuilder setDesc:@"kTransverseCanvasDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"transverse_canva@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyCoin price:1000];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //竖版画布
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:VerticalCanvas];
    [itemBuilder setName:@"kVerticalCanvas"];
    [itemBuilder setDesc:@"kVerticalCanvasDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"vertical_canvas@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyCoin price:1000];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //正方形画布(大)
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:SquareCanvasLarge];
    [itemBuilder setName:@"kSquareCanvasLarge"];
    [itemBuilder setDesc:@"kSquareCanvasLargeDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"square_canvas_large@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyIngot price:2];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];


    //横版画布(大)
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:TransverseCanvasLarge];
    [itemBuilder setName:@"kTransverseCanvasLarge"];
    [itemBuilder setDesc:@"kTransverseCanvasLargeDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"transverse_canvas_large@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyIngot price:2];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //竖版画布(大)
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:VerticalCanvasLarge];
    [itemBuilder setName:@"kVerticalCanvasLarge"];
    [itemBuilder setDesc:@"kVerticalCanvasLargeDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"vertical_canvas_large@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyIngot price:2];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //纹理背景包
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:VeinsBackground];
    [itemBuilder setName:@"kVeinsBackground"];
    [itemBuilder setDesc:@"kVeinsBackgroundDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"veins_background@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyIngot price:4];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //基本形状
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:BasicShape];
    [itemBuilder setName:@"kBasicShape"];
    [itemBuilder setDesc:@"kBasicShapeDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"Basic_Shape@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];


    priceInfo = [self currency:PBGameCurrencyIngot price:5];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];



    //钱袋
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:PurseItem];
    [itemBuilder setName:@"kPurseItem"];
    [itemBuilder setDesc:@"kPurseItemDescription"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeNonConsumable];
    [itemBuilder setImage:URL_ITEM_IMAGE(@"purse_item@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeTool];
    //[itemBuilder setAppleProductId:nil];


    priceInfo = [self currency:PBGameCurrencyIngot price:10];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:1];
    //[itemBuilder setUsageLifeUnit:nil];
    //[itemBuilder setUsageLife:0];
    [mutableArray addObject:[itemBuilder build]];

    //时间消耗品
    itemBuilder = [[[PBGameItem_Builder alloc] init] autorelease];
    [itemBuilder setItemId:1800];
    [itemBuilder setName:@"时间消耗品"];
    [itemBuilder setDesc:@"时间消耗品的描述"];
    [itemBuilder setConsumeType:PBGameItemConsumeTypeTimeConsumable];

    [itemBuilder setImage:URL_ITEM_IMAGE(@"时间消耗品@2x.png")];
    //[itemBuilder setDemoImage:nil];
    [itemBuilder setType:PBDrawItemTypeNomal];
    //[itemBuilder setAppleProductId:nil];

    priceInfo = [self currency:PBGameCurrencyCoin price:20];
    [itemBuilder setPriceInfo:priceInfo];
    //[itemBuilder setPromotionInfo:nil];

    //[itemBuilder setDefaultSaleCount:0];
    [itemBuilder setUsageLifeUnit:PBGameTimeUnitDay];
    [itemBuilder setUsageLife:1];
    [mutableArray addObject:[itemBuilder build]];


    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];

    //write to file
    NSString *filePath = @"/Users/Linruin/gitdata/shop_item.pb";
    if (![[list data] writeToFile:filePath atomically:YES]) {
    PPDebug(@"<createTestDataFile> error");
    } else {
    PPDebug(@"<createTestDataFile> succ");
    }

    [listBuilder release];
}


@end
