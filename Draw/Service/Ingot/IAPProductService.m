//
//  IAPProductService.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "IAPProductService.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "IAPProductManager.h"
#import "BlockArray.h"

@interface IAPProductService()
@property (retain, nonatomic) BlockArray *blockArray;
@property (retain, nonatomic) PPSmartUpdateData *smartData;
@end

@implementation IAPProductService

SYNTHESIZE_SINGLETON_FOR_CLASS(IAPProductService);

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
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:[IAPProductManager IAPProductFileName] type:SMART_UPDATE_DATA_TYPE_PB bundlePath:[IAPProductManager IAPProductFileBundlePath] initDataVersion:[IAPProductManager IAPProductFileVersion]] autorelease];
    }

    return self;
}

- (void)syncData:(GetIngotsListResultHandler)handler
{
    GetIngotsListResultHandler tempHandler = (GetIngotsListResultHandler)[_blockArray copyBlock:handler];
    
    __block typeof(self) bself = self;

    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        
        @try {
            NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
            NSArray *products = [[PBIAPProductList parseFromData:data] products];
            [[IAPProductManager defaultManager] setProductList:products];
            
            EXECUTE_BLOCK(tempHandler, YES, products);
            [bself.blockArray releaseBlock:tempHandler];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"getIngotsList failure error=%@", [error description]);
        NSData *data = [NSData dataWithContentsOfFile:bself.smartData.dataFilePath];
        NSArray *products = [[PBIAPProductList parseFromData:data] products];
        [[IAPProductManager defaultManager] setProductList:products];
        EXECUTE_BLOCK(tempHandler, NO, products);
        [bself.blockArray releaseBlock:tempHandler];
    }];
}

+ (void)createTestDataFile
{
#ifdef DEBUG
        [GameApp createIAPTestDataFile];
#endif

}

#define DRAW_INGOT_18_TAOBAO_URL @"http://a.m.taobao.com/i17800225785.htm?v=0&mz_key=0"
#define DRAW_INGOT_32_TAOBAO_URL @"http://a.m.taobao.com/i23762488264.htm?v=0&mz_key=0"
#define DRAW_INGOT_90_TAOBAO_URL @"http://a.m.taobao.com/i17800321867.htm?v=0&mz_key=0"
#define DRAW_INGOT_250_TAOBAO_URL @"http://a.m.taobao.com/i19665779806.htm?v=0&mz_key=0"

#define DRAW_COIN_10000_TAOBAO_URL @"http://a.m.taobao.com/i18806438949.htm?v=0&mz_key=0"
#define DRAW_COIN_20000_TAOBAO_URL @"http://a.m.taobao.com/i25865932315.htm?v=0&mz_key=0"
#define DRAW_COIN_80000_TAOBAO_URL @"http://a.m.taobao.com/i25865932473.htm?v=0&mz_key=0"
#define DRAW_COIN_250000_TAOBAO_URL @"http://a.m.taobao.com/i25865840952.htm?v=0&mz_key=0"

#define ZJH_COIN_10000_TAOBAO_URL @"http://a.m.taobao.com/i23758468517.htm?v=0&mz_key=0"
#define ZJH_COIN_18000_TAOBAO_URL @"http://a.m.taobao.com/i17798661047.htm?v=0&mz_key=0"
#define ZJH_COIN_66000_TAOBAO_URL @"http://a.m.taobao.com/i17798661364.htm?v=0&mz_key=0"
#define ZJH_COIN_180000_TAOBAO_URL @"http://a.m.taobao.com/i19663543354.htm?v=0&mz_key=0"

#define DICE_COIN_10000_TAOBAO_URL @"http://a.m.taobao.com/i19955183025.htm?v=0&mz_key=0"
#define DICE_COIN_18000_TAOBAO_URL @"http://a.m.taobao.com/i18015757670.htm?v=0&mz_key=0"
#define DICE_COIN_66000_TAOBAO_URL @"http://a.m.taobao.com/i18015793674.htm?v=0&mz_key=0"
#define DICE_COIN_180000_TAOBAO_URL @"http://a.m.taobao.com/i24207916662.htm?v=0&mz_key=0"


#define INGOT_6_TAOBAO_URL  @"http://a.m.taobao.com/i25015596629.htm?v=0&mz_key=0"
#define INGOT_22_TAOBAO_URL  @"http://a.m.taobao.com/i25015396557.htm?v=0&mz_key=0"
#define INGOT_39_TAOBAO_URL  @"http://a.m.taobao.com/i20479207896.htm?v=0&mz_key=0"
#define INGOT_84_TAOBAO_URL  @"http://a.m.taobao.com/i25015568861.htm?v=0&mz_key=0"
#define INGOT_225_TAOBAO_URL  @"http://a.m.taobao.com/i25015808160.htm?v=0&mz_key=0"
#define INGOT_600_TAOBAO_URL  @"http://a.m.taobao.com/i18392618241.htm?v=0&mz_key=0"

+ (void)createDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
//    priceCN = [self cnPriceWithPrice:@"12" saving:nil];
//    priceUS = [self usPriceWithPrice:@"1.99" saving:nil];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.draw.coin_10000"
//                                  alipayProductId:@"draw_coin_10000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:10000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_10000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:nil];
    priceUS = [self usPriceWithPrice:@"2.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_18"
//                                  alipayProductId:@"draw_ingot_18"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:18
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_18_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"30" saving:@"6%"];
    priceUS = [self usPriceWithPrice:@"4.99" saving:@"6%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_30"
//                                  alipayProductId:@"draw_ingot_30"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:32
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_32_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"24%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"24%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_68"
//                                  alipayProductId:@"draw_ingot_68"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:90
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_90_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"163" saving:@"35%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"35%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_163"
//                                  alipayProductId:@"draw_ingot_163"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:250
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_250_TAOBAO_URL
                                        priceList:priceList
                             ]];

    
//    priceCN = [self cnPriceWithPrice:@"18" saving:nil]; //@"25%"];
//    priceUS = [self usPriceWithPrice:@"2.99" saving:nil]; //@"25%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.draw.coin_20000"
//                                  alipayProductId:@"draw_coin_20000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:20000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_20000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
//    
//    priceCN = [self cnPriceWithPrice:@"68" saving:@"15%"];
//    priceUS = [self usPriceWithPrice:@"9.99" saving:@"15%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.draw.coin_80000"
//                                  alipayProductId:@"draw_coin_80000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:80000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_80000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
//    
//    priceCN = [self cnPriceWithPrice:@"163" saving:@"30%"];
//    priceUS = [self usPriceWithPrice:@"24.99" saving:@"30%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.draw.coin_250000"
//                                  alipayProductId:@"draw_coin_250000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:250000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_250000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
//
    
    
    
    PBIAPProductListBuilder *listBuilder = [[PBIAPProductListBuilder alloc] init];
    [listBuilder setProductsArray:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/gitdata/Draw_iPhone/Draw/Draw/Resource/Data/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createSingCoinsTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"18" saving:nil]; //@"25%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:nil]; //@"25%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.sing.coin_20000"
//                                  alipayProductId:@"draw_coin_20000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:20000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_COIN_20000_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"15%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"15%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.sing.coin_80000"
//                                  alipayProductId:@"draw_coin_80000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:80000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_COIN_80000_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"163" saving:@"30%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"30%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.sing.coin_250000"
//                                  alipayProductId:@"draw_coin_250000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:250000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_COIN_250000_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    
    
    PBIAPProductListBuilder *listBuilder = [[PBIAPProductListBuilder alloc] init];
    [listBuilder setProductsArray:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/Draw_iPhone/Draw/Sing/Resource/data/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (void)createLittlegeeIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
//    priceCN = [self cnPriceWithPrice:@"12" saving:nil];
//    priceUS = [self usPriceWithPrice:@"1.99" saving:nil];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.littlegee.coin_10000"
//                                  alipayProductId:@"draw_coin_10000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:10000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_10000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:nil];
    priceUS = [self usPriceWithPrice:@"2.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.littlegee.ingot_18"
//                                  alipayProductId:@"draw_ingot_18"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:18
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_18_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"30" saving:@"6%"];
    priceUS = [self usPriceWithPrice:@"4.99" saving:@"6%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.littlegee.ingot_32"
//                                  alipayProductId:@"draw_ingot_30"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:32
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_32_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"24%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"24%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.littlegee.ingot_90"
//                                  alipayProductId:@"draw_ingot_68"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:90
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_90_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    priceCN = [self cnPriceWithPrice:@"163" saving:@"35%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"35%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.littlegee.ingot_250"
//                                  alipayProductId:@"draw_ingot_163"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:250
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_250_TAOBAO_URL
                                        priceList:priceList
                             ]];

    
//    priceCN = [self cnPriceWithPrice:@"18" saving:nil]; //@"25%"];
//    priceUS = [self usPriceWithPrice:@"2.99" saving:nil]; // @"25%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.littlegee.coin_20000"
//                                  alipayProductId:@"draw_coin_20000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:20000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_20000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
//    
//    priceCN = [self cnPriceWithPrice:@"68" saving:@"15%"];
//    priceUS = [self usPriceWithPrice:@"9.99" saving:@"15%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.littlegee.coin_80000"
//                                  alipayProductId:@"draw_coin_80000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:80000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_80000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
//    
//    priceCN = [self cnPriceWithPrice:@"163" saving:@"30%"];
//    priceUS = [self usPriceWithPrice:@"24.99" saving:@"30%"];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
//                                   appleProductId:@"com.orange.littlegee.coin_250000"
//                                  alipayProductId:@"draw_coin_250000"
//                                             name:@"kCoin"
//                                             desc:@"kCoin"
//                                            count:250000
//                                       totalPrice:priceCN.price
//                                           saving:priceCN.saving
//                                        taobaoUrl:DRAW_COIN_250000_TAOBAO_URL
//                                        priceList:priceList
//                             ]];
    
    
    PBIAPProductListBuilder *listBuilder = [[PBIAPProductListBuilder alloc] init];
    [listBuilder setProductsArray:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
//    NSString *filePath = [@"~/gitdata/Draw_iPhone/Draw/LittleGeeDraw/Resource/Config/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
        NSString *filePath = [@"/gitdata/Draw_iPhone/Draw/LittleGeeDraw/Resource/Config" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (void)createLearnDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
//    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
//    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
//    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
//    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
//                                     appleProductId:@"com.orange.learndraw.ingot_6"
//                                    alipayProductId:@"learn_draw_ingot_6"
//                                               name:@"kIngot"
//                                               desc:@"kIngot"
//                                              count:6
//                                         totalPrice:priceUS.price
//                                             saving:priceUS.saving
//                                          taobaoUrl:nil
//                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_22"
//                                    alipayProductId:@"learn_draw_ingot_22"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:22
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"30" saving:@"23%"];
    priceUS = [self usPriceWithPrice:@"4.99" saving:@"23%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_39"
//                                    alipayProductId:@"learn_draw_ingot_39"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:39
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"28%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"28%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_84"
//                                    alipayProductId:@"learn_draw_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"163" saving:@"33%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"33%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_225"
//                                    alipayProductId:@"learn_draw_ingot_225"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:225
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"328" saving:@"50%"];
    priceUS = [self usPriceWithPrice:@"49.99" saving:@"50%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_600"
//                                    alipayProductId:@"learn_draw_ingot_600"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:600
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductListBuilder *listBuilder = [[PBIAPProductListBuilder alloc] init];
    [listBuilder setProductsArray:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/game/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createPureDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawpro.ingot_6"
//                                    alipayProductId:@"puredrawpro_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:INGOT_6_TAOBAO_URL
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawpro.ingot_22"
//                                    alipayProductId:@"puredrawpro_ingot_22"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:22
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:INGOT_22_TAOBAO_URL
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"30" saving:@"23%"];
    priceUS = [self usPriceWithPrice:@"4.99" saving:@"23%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawpro.ingot_39"
//                                    alipayProductId:@"puredrawpro_ingot_39"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:39
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:INGOT_39_TAOBAO_URL
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"28%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"28%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawpro.ingot_84"
//                                    alipayProductId:@"puredrawpro_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:INGOT_84_TAOBAO_URL
                                          priceList:priceList]];
    
    PBIAPProductListBuilder *listBuilder = [[PBIAPProductListBuilder alloc] init];
    [listBuilder setProductsArray:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/game/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}



+ (PBIAPProduct *)usProductWithType:(PBIAPProductType)type
                     appleProductId:(NSString *)appleProductId
//                    alipayProductId:(NSString *)alipayProductId
                               name:(NSString *)name
                               desc:(NSString *)desc
                              count:(int)count
                         totalPrice:(NSString *)totalPrice
                             saving:(NSString *)saving
                          taobaoUrl:(NSString *)taobaoUrl
{
    PBIAPProductBuilder *builder = [[[PBIAPProductBuilder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
//    [builder setAlipayProductId:alipayProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"$"];
    [builder setCountry:@"US"];
    [builder setTaobaoUrl:taobaoUrl];
    
    return [builder build];
}

+ (PBIAPProduct *)usProductWithType:(PBIAPProductType)type
                     appleProductId:(NSString *)appleProductId
                               name:(NSString *)name
                               desc:(NSString *)desc
                              count:(int)count
                         totalPrice:(NSString *)totalPrice
                             saving:(NSString *)saving
                          taobaoUrl:(NSString *)taobaoUrl
                          priceList:(NSArray*)priceList
{
    PBIAPProductBuilder *builder = [[[PBIAPProductBuilder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"$"];
    [builder setCountry:@"US"];
    [builder setTaobaoUrl:taobaoUrl];
    [builder setPricesArray:priceList];
    
    return [builder build];
}


+ (PBIAPProduct *)productWithType:(PBIAPProductType)type
                   appleProductId:(NSString *)appleProductId
                             name:(NSString *)name
                             desc:(NSString *)desc
                            count:(int)count
                       totalPrice:(NSString *)totalPrice
                           saving:(NSString *)saving
                        taobaoUrl:(NSString *)taobaoUrl
{
    PBIAPProductBuilder *builder = [[[PBIAPProductBuilder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"￥"];
    [builder setCountry:@"CN"];
    [builder setTaobaoUrl:taobaoUrl];
    
    return [builder build];
}

+ (PBIAPProduct *)productWithType:(PBIAPProductType)type
                   appleProductId:(NSString *)appleProductId
//                  alipayProductId:(NSString *)alipayProductId
                             name:(NSString *)name
                             desc:(NSString *)desc
                            count:(int)count
                       totalPrice:(NSString *)totalPrice
                           saving:(NSString *)saving
                        taobaoUrl:(NSString *)taobaoUrl
                        priceList:(NSArray *)priceList
{
    PBIAPProductBuilder *builder = [[[PBIAPProductBuilder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
//    [builder setAlipayProductId:alipayProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"￥"];
    [builder setCountry:@"CN"];
    [builder setTaobaoUrl:taobaoUrl];
    [builder setPricesArray:priceList];
    
    return [builder build];
}


+ (PBIAPProductPrice *)priceWithPrice:(NSString *)price
                   currency:(NSString *)currency
                    country:(NSString *)country
                     saving:(NSString *)saving
{
    PBIAPProductPriceBuilder *builder = [[[PBIAPProductPriceBuilder alloc] init] autorelease];
    [builder setPrice:price];
    [builder setCurrency:currency];
    [builder setCountry:country];
    [builder setSaving:saving];
    
    return [builder build];
}

+ (PBIAPProductPrice *)cnPriceWithPrice:(NSString *)price
                                 saving:(NSString *)saving
{
    return [self priceWithPrice:price currency:@"￥" country:@"CN" saving:saving];
}

+ (PBIAPProductPrice *)usPriceWithPrice:(NSString *)price
                                 saving:(NSString *)saving
{
    return [self priceWithPrice:price currency:@"$" country:@"US" saving:saving];
}





@end
