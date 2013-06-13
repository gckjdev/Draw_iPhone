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
#import "BlockArray.h"
#import "ItemType.h"
#import "NSDate+TKCategory.h"

@interface GameItemService()
@property (retain, nonatomic) BlockArray *blockArray;
@property (retain, nonatomic) PPSmartUpdateData *smartData;

@end

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    PPRelease(_smartData);
    [_blockArray releaseAllBlock];
    [_blockArray release];
    [super dealloc];
}

- (id)init
{
    if(self = [super init])
    {
        self.blockArray = [[[BlockArray alloc] init] autorelease];
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:[GameItemManager shopItemsFileName] type:SMART_UPDATE_DATA_TYPE_PB bundlePath:[GameItemManager shopItemsFileBundlePath] initDataVersion:[GameItemManager shopItemsFileVersion]] autorelease];
    }
    
    return self;
}


- (void)syncData:(SyncItemsDataResultHandler)handler
{
    PPDebug(@"sync item data");
    SyncItemsDataResultHandler tempHandler = (SyncItemsDataResultHandler)[_blockArray copyBlock:handler];
    
    __block typeof(self) bself = self;

    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        [bself updateItemsWithFile:dataFilePath];
        EXECUTE_BLOCK(tempHandler, YES);
        [bself.blockArray releaseBlock:tempHandler];
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        PPDebug(@"datafilepath = %@", bself.smartData.dataFilePath);
        NSArray *itemsList = [bself itemsListFromFile:bself.smartData.dataFilePath];
        [[GameItemManager defaultManager] setItemsList:itemsList];

        EXECUTE_BLOCK(tempHandler, NO);
        [bself.blockArray releaseBlock:tempHandler];
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
                 startDate:(NSDate *)startDate
                expireDate:(NSDate *)expireDate
{
    PBPromotionInfo_Builder *promotionInfoBuilder = [[PBPromotionInfo_Builder alloc] init];
    [promotionInfoBuilder setPrice:price];
    [promotionInfoBuilder setStartDate:[startDate timeIntervalSince1970]];
    [promotionInfoBuilder setExpireDate:[expireDate  timeIntervalSince1970]];
    PBPromotionInfo *promotionInfo = [promotionInfoBuilder build];
    [promotionInfoBuilder release];
    return promotionInfo;
}

#define DRAW_URL_ITEM_IMAGE(name) [NSString stringWithFormat:@"http://58.215.160.100:8080/app_res/smart_data/shop_item_images_Draw/%@", name]
#define DICE_URL_ITEM_IMAGE(name) [NSString stringWithFormat:@"http://58.215.160.100:8080/app_res/smart_data/shop_item_images_Dice/%@", name]


+ (void)createTestDataFile
{
    if (isLittleGeeAPP()){
        [self createLittlegeeTestDataFile];
    }
    else if (isDrawApp()) {
        [self createDrawTestDataFile];
    }else if(isDiceApp()){
        [self createDiceTestDataFile];
    }else if (isSimpleDrawApp()){
        [self createLearnDrawTestDataFile];
    }
}

+ (void)createDiceTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    // 重摇
    [mutableArray addObject:[self itemWithItemId:ItemTypeRollAgain
                                            name:@"kItemRollAgain"
                                            desc:@"kRollAgainDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_roll_again@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:200
                                        currency:PBGameCurrencyCoin]];
    
    // 劈
    [mutableArray addObject:[self itemWithItemId:ItemTypeCut
                                            name:@"kItemCut"
                                            desc:@"kCutDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_cut@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:100
                                        currency:PBGameCurrencyCoin]];
    
    // 看
    [mutableArray addObject:[self itemWithItemId:ItemTypePeek
                                            name:@"kItemPeek"
                                            desc:@"kPeekDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_eye@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:50
                                        currency:PBGameCurrencyCoin]];
    
    // 延时
    [mutableArray addObject:[self itemWithItemId:ItemTypeIncTime
                                            name:@"kItemPostpone"
                                            desc:@"kPostponeDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_delay@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:50
                                        currency:PBGameCurrencyCoin]];
    
    // 减时
    [mutableArray addObject:[self itemWithItemId:ItemTypeDecTime
                                            name:@"kItemUrge"
                                            desc:@"kUrgeDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_hurryup@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:50
                                        currency:PBGameCurrencyCoin]];
    
    // 龟缩
    [mutableArray addObject:[self itemWithItemId:ItemTypeSkip
                                            name:@"kItemTurtle"
                                            desc:@"kTurtleDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_tortoise@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:150
                                        currency:PBGameCurrencyCoin]];
    
    // 机器人
    [mutableArray addObject:[self itemWithItemId:ItemTypeDiceRobot
                                            name:@"kItemDiceRobot"
                                            desc:@"kDiceRobotDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_robot@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:50
                                        currency:PBGameCurrencyCoin]];
    
    // 逆
    [mutableArray addObject:[self itemWithItemId:ItemTypeReverse
                                            name:@"kItemReverse"
                                            desc:@"kReverseDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_reverse@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:100
                                        currency:PBGameCurrencyCoin]];
    
    // 爱国骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDicePatriotDice
                                            name:@"kItemPatriotDice"
                                            desc:@"kPatriotDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_patriot_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 金色骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceGoldenDice
                                            name:@"kItemGoldenDice"
                                            desc:@"kGoldenDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_golden_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 木质骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceWoodDice
                                            name:@"kItemWoodDice"
                                            desc:@"kWoodDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_wood_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 蓝宝石骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceBlueCrystalDice
                                            name:@"kItemBlueCrystalDice"
                                            desc:@"kBlueCrystalDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_blue_crystal_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];

    // 粉色宝石骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDicePinkCrystalDice
                                            name:@"kItemPinkCrystalDice"
                                            desc:@"kPinkCrystalDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_pink_crystal_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 绿宝石骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceGreenCrystalDice
                                            name:@"kItemGreenCrystalDice"
                                            desc:@"kGreenCrystalDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_green_crystal_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 紫宝石骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDicePurpleCrystalDice
                                            name:@"kItemPurpleCrystalDice"
                                            desc:@"kPurpleCrystalDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_purple_crystal_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 蓝钻骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceBlueDiamondDice
                                            name:@"kItemBlueDiamondDice"
                                            desc:@"kBlueDiamondDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_blue_diamond_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 粉钻骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDicePinkDiamondDice
                                            name:@"kItemPinkDiamondDice"
                                            desc:@"kPinkDiamondDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_pink_diamond_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 绿钻骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDiceGreenDiamondDice
                                            name:@"kItemGreenDiamondDice"
                                            desc:@"kGreenDiamondDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_green_diamond_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];
    
    // 紫钻骰子
    [mutableArray addObject:[self itemWithItemId:ItemTypeCustomDicePurpleDiamondDice
                                            name:@"kItemPurpleDiamondDice"
                                            desc:@"kPurpleDiamondDiceDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DICE_URL_ITEM_IMAGE(@"shop_item_purple_diamond_dice@2x.png")
                                            type:PBDiceItemTypeDiceNomal
                                           price:20000
                                        currency:PBGameCurrencyCoin]];


    
    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];
    
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (void)createDrawTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    int discount = 1;       // if 1, no discount, 2, 50% discount
    
    // 鲜花
    [mutableArray addObject:[self itemWithItemId:ItemTypeFlower
                                            name:@"kFlower"
                                            desc:@"kFlowerDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_flower@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:20
                                        currency:PBGameCurrencyCoin]];
    
    //    // 番茄
    //    [mutableArray addObject:[self itemWithItemId:ItemTypeTomato
    //                                            name:@"kTomato"
    //                                            desc:@"kTomatoDescription"
    //                                     consumeType:PBGameItemConsumeTypeAmountConsumable
    //                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_tomato@2x.png")
    //                                            type:PBDrawItemTypeNomal
    //                                           price:20
    //                                        currency:PBGameCurrencyCoin]];
    
    // 锦囊
    [mutableArray addObject:[self itemWithItemId:ItemTypeTips
                                            name:@"kTips"
                                            desc:@"kTipsDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_tipbag@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:20
                                        currency:PBGameCurrencyCoin]];
    
    // 颜色
    [mutableArray addObject:[self itemWithItemId:ItemTypeColor
                                            name:@"kColor"
                                            desc:@"kColorDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_print_oil@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:100
                                        currency:PBGameCurrencyCoin]];
    
    // 广告拦截器
    [mutableArray addObject:[self itemWithItemId:ItemTypeRemoveAd
                                            name:@"kRemoveAd"
                                            desc:@"kRemoveAdDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_clean_ad@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:10
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:10/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 钱箱
    [mutableArray addObject:[self itemWithItemId:ItemTypePurse
                                            name:@"kItemTypePurse"
                                            desc:@"kItemTypePurseDesc"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_purse@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:10
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:5
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]
                                defaultSaleCount:1]];
    
    
    // 透明笔
    [mutableArray addObject:[self itemWithItemId:ColorAlphaItem
                                            name:@"kColorAlphaItem"
                                            desc:@"kColorAlphaItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:10
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:10/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    // 吸管
    [mutableArray addObject:[self itemWithItemId:ColorStrawItem
                                            name:@"kStraw"
                                            desc:@"kStrawDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_straw@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1500
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:1500/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 作品播放器
    [mutableArray addObject:[self itemWithItemId:PaintPlayerItem
                                            name:@"kPaintPlayerItem"
                                            desc:@"kPaintPlayerItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_paint_player@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];

    
    // 调色盘
    [mutableArray addObject:[self itemWithItemId:PaletteItem
                                            name:@"kPaletteItem"
                                            desc:@"kPaletteItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_palette@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4000
                                        currency:PBGameCurrencyCoin
                                  promotionPrice:2000
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    //基本形状
    [mutableArray addObject:[self itemWithItemId:BasicShape
                                            name:@"kBasicShape"
                                            desc:@"kBasicShapeDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_basic_shape@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:5
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:5/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    
    // 网格参考线
    [mutableArray addObject:[self itemWithItemId:ItemTypeGrid
                                            name:@"kItemTypeGrid"
                                            desc:@"kItemTypeGridDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_grid@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1500
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:1500/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景1
    [mutableArray addObject:[self itemWithItemId:DrawBackground1
                                            name:@"kDrawBgAntares"
                                            desc:@"kDrawBgAntaresDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_antares@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:2
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景2
    [mutableArray addObject:[self itemWithItemId:DrawBackground2
                                            name:@"kDrawBgAdhara"
                                            desc:@"kDrawBgAdharaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_adhara@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:2
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    // 背景3
    [mutableArray addObject:[self itemWithItemId:DrawBackground3
                                            name:@"kDrawBgElnath"
                                            desc:@"kDrawBgElnathDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_elnath@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:2
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 背景4
    [mutableArray addObject:[self itemWithItemId:DrawBackground4
                                            name:@"kDrawBgAlioth"
                                            desc:@"kDrawBgAliothDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_alioth@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景5
    [mutableArray addObject:[self itemWithItemId:DrawBackground5
                                            name:@"kDrawBgMimosa"
                                            desc:@"kDrawBgMimosaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mimosa@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景6
    [mutableArray addObject:[self itemWithItemId:DrawBackground6
                                            name:@"kDrawBgArcturus"
                                            desc:@"kDrawBgArcturusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_arcturus@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景7
    [mutableArray addObject:[self itemWithItemId:DrawBackground7
                                            name:@"kDrawBgPollux"
                                            desc:@"kDrawBgPolluxDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_pollux@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景8
    [mutableArray addObject:[self itemWithItemId:DrawBackground8
                                            name:@"kDrawBgRegulus"
                                            desc:@"kDrawBgRegulusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_regulus@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景9
    [mutableArray addObject:[self itemWithItemId:DrawBackground9
                                            name:@"kDrawBgMirfak"
                                            desc:@"kDrawBgMirfakDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mirfak@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 正方形画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadLarge
                                            name:@"kSquareCanvasLarge"
                                            desc:@"kSquareCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_square_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot  //]];
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadHorizontal
                                            name:@"kHorizontalCanvasSmall"
                                            desc:@"kHorizontalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenHorizontal
                                            name:@"kHorizontalCanvas"
                                            desc:@"kHorizontalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:2/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Horizontal
                                            name:@"kHorizontalCanvasLarge"
                                            desc:@"kHorizontalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 竖版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadVertical
                                            name:@"kVerticalCanvasSmall"
                                            desc:@"kVerticalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 竖版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenVertical
                                            name:@"kVerticalCanvas"
                                            desc:@"kVerticalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:2/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 竖版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Vertical
                                            name:@"kVerticalCanvasLarge"
                                            desc:@"kVerticalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:4/discount
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 维锐电容笔（大）
    [mutableArray addObject:[self itemWithItemId:ItemTypeTaoBao
                                            name:@"维锐魔法师电容笔"
                                            desc:@"【促销】赠送10个元宝！知名品牌，原装正品，仅售79元，全网最优惠价格"
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_taobao_weirui_pen1.png")
                             
                                            type:PBDrawItemTypeDrawTaoBao
                                             url:@"http://a.m.taobao.com/i17538377874.htm"]];
    
    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];
    
    //write to file
//    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];
    NSString *filePath = [@"/gitdata/Draw_iPhone/Draw/Draw/Resource/Data/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];

    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createLittlegeeTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    // 鲜花
    [mutableArray addObject:[self itemWithItemId:ItemTypeFlower
                                            name:@"kFlower"
                                            desc:@"kFlowerDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_flower@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:20
                                        currency:PBGameCurrencyCoin]];
    
    //    // 番茄
    //    [mutableArray addObject:[self itemWithItemId:ItemTypeTomato
    //                                            name:@"kTomato"
    //                                            desc:@"kTomatoDescription"
    //                                     consumeType:PBGameItemConsumeTypeAmountConsumable
    //                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_tomato@2x.png")
    //                                            type:PBDrawItemTypeNomal
    //                                           price:20
    //                                        currency:PBGameCurrencyCoin]];
    
    // 锦囊
    [mutableArray addObject:[self itemWithItemId:ItemTypeTips
                                            name:@"kTips"
                                            desc:@"kTipsDescription"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_tipbag@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:20
                                        currency:PBGameCurrencyCoin]];
    
    // 颜色
    [mutableArray addObject:[self itemWithItemId:ItemTypeColor
                                            name:@"kColor"
                                            desc:@"kColorDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_print_oil@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:100
                                        currency:PBGameCurrencyCoin]];
    
    // 广告拦截器
    [mutableArray addObject:[self itemWithItemId:ItemTypeRemoveAd
                                            name:@"kRemoveAd"
                                            desc:@"kRemoveAdDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_clean_ad@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:10
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:10
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 钱箱
    [mutableArray addObject:[self itemWithItemId:ItemTypePurse
                                            name:@"kItemTypePurse"
                                            desc:@"kItemTypePurseDesc"
                                     consumeType:PBGameItemConsumeTypeAmountConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_purse@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:10
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:10
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]
                                defaultSaleCount:1]];
    
    
    // 透明笔
    [mutableArray addObject:[self itemWithItemId:ColorAlphaItem
                                            name:@"kColorAlphaItem"
                                            desc:@"kColorAlphaItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:10
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:10
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    // 吸管
    [mutableArray addObject:[self itemWithItemId:ColorStrawItem
                                            name:@"kStraw"
                                            desc:@"kStrawDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_straw@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1500
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:1500
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 作品播放器
    [mutableArray addObject:[self itemWithItemId:PaintPlayerItem
                                            name:@"kPaintPlayerItem"
                                            desc:@"kPaintPlayerItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_paint_player@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 调色盘
    [mutableArray addObject:[self itemWithItemId:PaletteItem
                                            name:@"kPaletteItem"
                                            desc:@"kPaletteItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_palette@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4000
                                        currency:PBGameCurrencyCoin
                                  promotionPrice:4000
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    //基本形状
    [mutableArray addObject:[self itemWithItemId:BasicShape
                                            name:@"kBasicShape"
                                            desc:@"kBasicShapeDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_basic_shape@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:5
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:5
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    
    // 网格参考线
    [mutableArray addObject:[self itemWithItemId:ItemTypeGrid
                                            name:@"kItemTypeGrid"
                                            desc:@"kItemTypeGridDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_grid@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1500
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:1500
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景1
    [mutableArray addObject:[self itemWithItemId:DrawBackground1
                                            name:@"kDrawBgAntares"
                                            desc:@"kDrawBgAntaresDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_antares@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景2
    [mutableArray addObject:[self itemWithItemId:DrawBackground2
                                            name:@"kDrawBgAdhara"
                                            desc:@"kDrawBgAdharaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_adhara@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    // 背景3
    [mutableArray addObject:[self itemWithItemId:DrawBackground3
                                            name:@"kDrawBgElnath"
                                            desc:@"kDrawBgElnathDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_elnath@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 背景4
    [mutableArray addObject:[self itemWithItemId:DrawBackground4
                                            name:@"kDrawBgAlioth"
                                            desc:@"kDrawBgAliothDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_alioth@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景5
    [mutableArray addObject:[self itemWithItemId:DrawBackground5
                                            name:@"kDrawBgMimosa"
                                            desc:@"kDrawBgMimosaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mimosa@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景6
    [mutableArray addObject:[self itemWithItemId:DrawBackground6
                                            name:@"kDrawBgArcturus"
                                            desc:@"kDrawBgArcturusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_arcturus@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景7
    [mutableArray addObject:[self itemWithItemId:DrawBackground7
                                            name:@"kDrawBgPollux"
                                            desc:@"kDrawBgPolluxDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_pollux@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景8
    [mutableArray addObject:[self itemWithItemId:DrawBackground8
                                            name:@"kDrawBgRegulus"
                                            desc:@"kDrawBgRegulusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_regulus@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景9
    [mutableArray addObject:[self itemWithItemId:DrawBackground9
                                            name:@"kDrawBgMirfak"
                                            desc:@"kDrawBgMirfakDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mirfak@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 正方形画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadLarge
                                            name:@"kSquareCanvasLarge"
                                            desc:@"kSquareCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_square_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot  //]];
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadHorizontal
                                            name:@"kHorizontalCanvasSmall"
                                            desc:@"kHorizontalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenHorizontal
                                            name:@"kHorizontalCanvas"
                                            desc:@"kHorizontalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:2
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 横版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Horizontal
                                            name:@"kHorizontalCanvasLarge"
                                            desc:@"kHorizontalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 竖版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadVertical
                                            name:@"kVerticalCanvasSmall"
                                            desc:@"kVerticalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2000
                                        currency:PBGameCurrencyCoin //]];
                                  promotionPrice:2000
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 竖版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenVertical
                                            name:@"kVerticalCanvas"
                                            desc:@"kVerticalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:2
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 竖版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Vertical
                                            name:@"kVerticalCanvasLarge"
                                            desc:@"kVerticalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:4
                                        currency:PBGameCurrencyIngot //]];
                                  promotionPrice:4
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 维锐电容笔（大）
    [mutableArray addObject:[self itemWithItemId:ItemTypeTaoBao
                                            name:@"维锐魔法师电容笔"
                                            desc:@"【促销】赠送10个元宝！知名品牌，原装正品，仅售79元，全网最优惠价格"
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_taobao_weirui_pen1.png")
                             
                                            type:PBDrawItemTypeDrawTaoBao
                                             url:@"http://a.m.taobao.com/i17538377874.htm"]];
    
    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];
    
    //write to file
    //    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];
    NSString *filePath = [@"/gitdata/Draw_iPhone/Draw/Draw/Resource/Data/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];
    
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


//+ (void)createLittlegeeTestDataFile
//{
//    // currently the file is the same
//    [self createDrawTestDataFile];
//}

+ (void)createLearnDrawTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];

    // 透明笔
    [mutableArray addObject:[self itemWithItemId:ColorAlphaItem
                                            name:@"kColorAlphaItem"
                                            desc:@"kColorAlphaItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_alpha@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:5
                                        currency:PBGameCurrencyIngot]];
    
    
    
    // 吸管
    [mutableArray addObject:[self itemWithItemId:ColorStrawItem
                                            name:@"kStraw"
                                            desc:@"kStrawDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_straw@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    
    // 调色盘
    [mutableArray addObject:[self itemWithItemId:PaletteItem
                                            name:@"kPaletteItem"
                                            desc:@"kPaletteItemDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_palette@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot]];
    
    //基本形状
    [mutableArray addObject:[self itemWithItemId:BasicShape
                                            name:@"kBasicShape"
                                            desc:@"kBasicShapeDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_basic_shape@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    
    
    
    // 网格参考线
    [mutableArray addObject:[self itemWithItemId:ItemTypeGrid
                                            name:@"kItemTypeGrid"
                                            desc:@"kItemTypeGridDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_grid@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    // 广告拦截器
    [mutableArray addObject:[self itemWithItemId:ItemTypeRemoveAd
                                            name:@"kRemoveAd"
                                            desc:@"kRemoveAdDescription"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_clean_ad@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:10
                                        currency:PBGameCurrencyIngot]];    
    
    // 背景1
    [mutableArray addObject:[self itemWithItemId:DrawBackground1
                                            name:@"kDrawBgAntares"
                                            desc:@"kDrawBgAntaresDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_antares@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景2
    [mutableArray addObject:[self itemWithItemId:DrawBackground2
                                            name:@"kDrawBgAdhara"
                                            desc:@"kDrawBgAdharaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_adhara@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    
    // 背景3
    [mutableArray addObject:[self itemWithItemId:DrawBackground3
                                            name:@"kDrawBgElnath"
                                            desc:@"kDrawBgElnathDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_elnath@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    
    // 背景4
    [mutableArray addObject:[self itemWithItemId:DrawBackground4
                                            name:@"kDrawBgAlioth"
                                            desc:@"kDrawBgAliothDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_alioth@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景5
    [mutableArray addObject:[self itemWithItemId:DrawBackground5
                                            name:@"kDrawBgMimosa"
                                            desc:@"kDrawBgMimosaDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mimosa@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景6
    [mutableArray addObject:[self itemWithItemId:DrawBackground6
                                            name:@"kDrawBgArcturus"
                                            desc:@"kDrawBgArcturusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_arcturus@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景7
    [mutableArray addObject:[self itemWithItemId:DrawBackground7
                                            name:@"kDrawBgPollux"
                                            desc:@"kDrawBgPolluxDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_pollux@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景8
    [mutableArray addObject:[self itemWithItemId:DrawBackground8
                                            name:@"kDrawBgRegulus"
                                            desc:@"kDrawBgRegulusDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_regulus@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 背景9
    [mutableArray addObject:[self itemWithItemId:DrawBackground9
                                            name:@"kDrawBgMirfak"
                                            desc:@"kDrawBgMirfakDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_draw_bg_mirfak@2x.png")
                                            type:PBDrawItemTypeDrawNomal
                                           price:2
                                        currency:PBGameCurrencyIngot
                                  promotionPrice:1
                                       startDate:[NSDate date]
                                      expireDate:[[NSDate date] dateByAddingDays:90]]];
    
    // 正方形画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadLarge
                                            name:@"kSquareCanvasLarge"
                                            desc:@"kSquareCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_square_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:2
                                        currency:PBGameCurrencyIngot]];
    
    // 横版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadHorizontal
                                            name:@"kHorizontalCanvasSmall"
                                            desc:@"kHorizontalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    // 横版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenHorizontal
                                            name:@"kHorizontalCanvas"
                                            desc:@"kHorizontalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    // 横版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Horizontal
                                            name:@"kHorizontalCanvasLarge"
                                            desc:@"kHorizontalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_horizontal_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    
    // 竖版画布（小）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadVertical
                                            name:@"kVerticalCanvasSmall"
                                            desc:@"kVerticalCanvasSmallDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    // 竖版画布（中）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPadScreenVertical
                                            name:@"kVerticalCanvas"
                                            desc:@"kVerticalCanvasDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    // 竖版画布（大）
    [mutableArray addObject:[self itemWithItemId:CanvasRectiPhone5Vertical
                                            name:@"kVerticalCanvasLarge"
                                            desc:@"kVerticalCanvasLargeDesc"
                                     consumeType:PBGameItemConsumeTypeNonConsumable
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_vertical_canvas@2x.png")
                                            type:PBDrawItemTypeDrawTool
                                           price:1
                                        currency:PBGameCurrencyIngot]];
    
    
    // 维锐电容笔（大）
    [mutableArray addObject:[self itemWithItemId:ItemTypeTaoBao
                                            name:@"维锐魔法师电容笔"
                                            desc:@"知名品牌，原装正品，包邮79元，全网最平价格，额外赠送5个元宝"
                                           image:DRAW_URL_ITEM_IMAGE(@"shop_item_taobao_weirui_pen1.png")
                             
                                            type:PBDrawItemTypeDrawTaoBao
                                             url:@"http://a.m.taobao.com/i17538377874.htm"]];
    
    PBGameItemList_Builder* listBuilder = [[PBGameItemList_Builder alloc] init];
    [listBuilder addAllItems:mutableArray];
    PBGameItemList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/game/" stringByAppendingPathComponent:[GameItemManager shopItemsFileName]];
    
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}




+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                           url:(NSString *)url
{
    return [self itemWithItemId:itemId
                           name:name
                           desc:desc
                    consumeType:0
                          image:image
                           type:type
                            url:url
                          price:0
                       currency:0
                 promotionPrice:0
                      startDate:nil
                     expireDate:nil
               defaultSaleCount:0
                  usageLifeUnit:0
                      usageLife:0];
}

+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                   consumeType:(PBGameItemConsumeType)consumeType
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                         price:(int)price
                      currency:(PBGameCurrency)currency
              defaultSaleCount:(int)defaultSaleCount
{
    return [self itemWithItemId:itemId
                           name:name
                           desc:desc
                    consumeType:consumeType
                          image:image
                           type:type
                            url:nil
                          price:price
                       currency:currency
                 promotionPrice:0
                      startDate:nil
                     expireDate:nil
               defaultSaleCount:defaultSaleCount
                  usageLifeUnit:0
                      usageLife:0];
}

+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                   consumeType:(PBGameItemConsumeType)consumeType
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                         price:(int)price
                      currency:(PBGameCurrency)currency
{
    return [self itemWithItemId:itemId
                           name:name
                           desc:desc
                    consumeType:consumeType
                          image:image
                           type:type
                          price:price
                       currency:currency
                 promotionPrice:price
                      startDate:nil
                     expireDate:nil];
}

+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                   consumeType:(PBGameItemConsumeType)consumeType
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                         price:(int)price
                      currency:(PBGameCurrency)currency
                promotionPrice:(int)promotionPrice
                     startDate:(NSDate*)startDate
                    expireDate:(NSDate*)expireDate
              defaultSaleCount:(int)defaultSaleCount
{    
    return [self itemWithItemId:itemId
                           name:name
                           desc:desc
                    consumeType:consumeType
                          image:image
                           type:type
                            url:nil
                          price:price
                       currency:currency
                 promotionPrice:promotionPrice
                      startDate:startDate
                     expireDate:expireDate
               defaultSaleCount:defaultSaleCount
                  usageLifeUnit:0
                      usageLife:0];
}

+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                   consumeType:(PBGameItemConsumeType)consumeType
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                         price:(int)price
                      currency:(PBGameCurrency)currency
                promotionPrice:(int)promotionPrice
                     startDate:(NSDate*)startDate
                    expireDate:(NSDate*)expireDate
{
    int defaultSaleCount = 1;
    if (consumeType == PBGameItemConsumeTypeAmountConsumable) {
        defaultSaleCount = 10;
    }
    
    return [self itemWithItemId:itemId
                           name:name
                           desc:desc
                    consumeType:consumeType
                          image:image
                           type:type
                            url:nil
                          price:price
                       currency:currency
                 promotionPrice:promotionPrice
                      startDate:startDate
                     expireDate:expireDate
               defaultSaleCount:defaultSaleCount
                  usageLifeUnit:0
                      usageLife:0];
}

+ (PBGameItem *)itemWithItemId:(int)itemId
                          name:(NSString *)name
                          desc:(NSString *)desc
                   consumeType:(PBGameItemConsumeType)consumeType
                         image:(NSString *)image
                          type:(PBDrawItemType)type
                           url:(NSString *)url
                         price:(int)price
                      currency:(PBGameCurrency)currency
                promotionPrice:(int)promotionPrice
                     startDate:(NSDate*)startDate
                    expireDate:(NSDate*)expireDate
              defaultSaleCount:(int)defaultSaleCount
                 usageLifeUnit:(PBGameTimeUnit)usageLifeUnit
                     usageLife:(int)usageLife;
{
    PBGameItem_Builder *builder = [[[PBGameItem_Builder alloc] init] autorelease];
    [builder setItemId:itemId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setConsumeType:consumeType];
    [builder setImage:image];
    [builder setType:type];
    [builder setUrl:url];
    [builder setPriceInfo:[self currency:currency price:price]];
    if (promotionPrice < price || promotionPrice < 0){
        [builder setPromotionInfo:[self price:promotionPrice startDate:startDate expireDate:expireDate]];
    }
    [builder setDefaultSaleCount:defaultSaleCount];
    [builder setUsageLifeUnit:usageLifeUnit];
    [builder setUsageLife:usageLife];
    return [builder build];
}


@end
