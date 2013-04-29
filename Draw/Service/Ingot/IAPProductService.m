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
        self.smartData = [[PPSmartUpdateData alloc] initWithName:[IAPProductManager IAPProductFileName] type:SMART_UPDATE_DATA_TYPE_PB bundlePath:[IAPProductManager IAPProductFileBundlePath] initDataVersion:[IAPProductManager IAPProductFileVersion]];
    }

    return self;
}

- (void)syncData:(GetIngotsListResultHandler)handler
{
    GetIngotsListResultHandler tempHandler = (GetIngotsListResultHandler)[_blockArray copyBlock:handler];
    
    __block typeof(self) bself = self;

    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *products = [[PBIAPProductList parseFromData:data] productsList];
        [[IAPProductManager defaultManager] setProductList:products];
        
        EXECUTE_BLOCK(tempHandler, YES, products);
        [bself.blockArray releaseBlock:tempHandler];
    } failureBlock:^(NSError *error) {
        PPDebug(@"getIngotsList failure error=%@", [error description]);
        NSData *data = [NSData dataWithContentsOfFile:bself.smartData.dataFilePath];
        NSArray *products = [[PBIAPProductList parseFromData:data] productsList];
        [[IAPProductManager defaultManager] setProductList:products];
        EXECUTE_BLOCK(tempHandler, NO, products);
        [bself.blockArray releaseBlock:tempHandler];
    }];
}

+ (void)createTestDataFile
{
    if (isDrawApp()) {
        [self createDrawIngotTestDataFile];
    }else if (isZhajinhuaApp()){
        [self createZJHCoinTestDataFile];
    }else if(isDiceApp()){
        [self createDiceCoinTestDataFile];
    }else if (isLearnDrawApp()){
        [self createLearnDrawIngotTestDataFile];
    }else if(isPureDrawApp()){
        [self createPureDrawIngotTestDataFile];
    }else if(isPureDrawFreeApp()){
        [self createPureDrawFreeIngotTestDataFile];
    }else if(isPhotoDrawApp()){
        [self createPhotoDrawIngotTestDataFile];
    }else if(isPhotoDrawFreeApp()){
        [self createPhotoDrawFreeIngotTestDataFile];
    }
}

#define DRAW_INGOT_18_TAOBAO_URL @"http://a.m.taobao.com/i17800225785.htm?v=0&mz_key=0"
#define DRAW_INGOT_32_TAOBAO_URL @"http://a.m.taobao.com/i23762488264.htm?v=0&mz_key=0"
#define DRAW_INGOT_90_TAOBAO_URL @"http://a.m.taobao.com/i17800321867.htm?v=0&mz_key=0"
#define DRAW_INGOT_250_TAOBAO_URL @"http://a.m.taobao.com/i19665779806.htm?v=0&mz_key=0"

#define ZJH_COIN_10000_TAOBAO_URL @"http://a.m.taobao.com/i23758468517.htm?v=0&mz_key=0"
#define ZJH_COIN_18000_TAOBAO_URL @"http://a.m.taobao.com/i17798661047.htm?v=0&mz_key=0"
#define ZJH_COIN_66000_TAOBAO_URL @"http://a.m.taobao.com/i17798661364.htm?v=0&mz_key=0"
#define ZJH_COIN_180000_TAOBAO_URL @"http://a.m.taobao.com/i19663543354.htm?v=0&mz_key=0"

#define DICE_COIN_10000_TAOBAO_URL @"http://a.m.taobao.com/i19955183025.htm?v=0&mz_key=0"
#define DICE_COIN_18000_TAOBAO_URL @"http://a.m.taobao.com/i18015757670.htm?v=0&mz_key=0"
#define DICE_COIN_66000_TAOBAO_URL @"http://a.m.taobao.com/i18015793674.htm?v=0&mz_key=0"
#define DICE_COIN_180000_TAOBAO_URL @"http://a.m.taobao.com/i24207916662.htm?v=0&mz_key=0"

+ (void)createDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"18" saving:nil];
    priceUS = [self usPriceWithPrice:@"2.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_18"
                                  alipayProductId:@"draw_ingot_18"
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
                                  alipayProductId:@"draw_ingot_30"
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
                                  alipayProductId:@"draw_ingot_68"
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
                                  alipayProductId:@"draw_ingot_163"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:250
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DRAW_INGOT_250_TAOBAO_URL
                                        priceList:priceList
                             ]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
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
    
    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_6"
                                    alipayProductId:@"learn_draw_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.learndraw.ingot_22"
                                    alipayProductId:@"learn_draw_ingot_22"
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
                                    alipayProductId:@"learn_draw_ingot_39"
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
                                    alipayProductId:@"learn_draw_ingot_84"
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
                                    alipayProductId:@"learn_draw_ingot_225"
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
                                    alipayProductId:@"learn_draw_ingot_600"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:600
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
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
                                    alipayProductId:@"puredrawpro_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawpro.ingot_22"
                                    alipayProductId:@"puredrawpro_ingot_22"
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
                                     appleProductId:@"com.orange.puredrawpro.ingot_39"
                                    alipayProductId:@"puredrawpro_ingot_39"
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
                                     appleProductId:@"com.orange.puredrawpro.ingot_84"
                                    alipayProductId:@"puredrawpro_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (void)createPureDrawFreeIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawfree.ingot_6"
                                    alipayProductId:@"puredrawfree_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.puredrawfree.ingot_22"
                                    alipayProductId:@"puredrawfree_ingot_22"
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
                                     appleProductId:@"com.orange.puredrawfree.ingot_39"
                                    alipayProductId:@"puredrawfree_ingot_39"
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
                                     appleProductId:@"com.orange.puredrawfree.ingot_84"
                                    alipayProductId:@"puredrawfree_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createPhotoDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.photodrawpro.ingot_6"
                                    alipayProductId:@"photodrawpro_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.photodrawpro.ingot_22"
                                    alipayProductId:@"photodrawpro_ingot_22"
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
                                     appleProductId:@"com.orange.photodrawpro.ingot_39"
                                    alipayProductId:@"photodrawpro_ingot_39"
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
                                     appleProductId:@"com.orange.photodrawpro.ingot_84"
                                    alipayProductId:@"photodrawpro_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createPhotoDrawFreeIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"6" saving:nil];
    priceUS = [self usPriceWithPrice:@"0.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.photodraw.ingot_6"
                                    alipayProductId:@"photodraw_ingot_6"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:6
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"18%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"18%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self usProductWithType:PBIAPProductTypeIapingot
                                     appleProductId:@"com.orange.photodraw.ingot_22"
                                    alipayProductId:@"photodraw_ingot_22"
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
                                     appleProductId:@"com.orange.photodraw.ingot_39"
                                    alipayProductId:@"photodraw_ingot_39"
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
                                     appleProductId:@"com.orange.photodraw.ingot_84"
                                    alipayProductId:@"photodraw_ingot_84"
                                               name:@"kIngot"
                                               desc:@"kIngot"
                                              count:84
                                         totalPrice:priceUS.price
                                             saving:priceUS.saving
                                          taobaoUrl:nil
                                          priceList:priceList]];
    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (void)createZJHCoinTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"12" saving:nil];
    priceUS = [self usPriceWithPrice:@"1.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins1200"
                                  alipayProductId:@"zjh_coin_1200"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                           count:10000
                                      totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:ZJH_COIN_10000_TAOBAO_URL
                                        priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"15%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"15%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins2400"
                                  alipayProductId:@"zjh_coin_2400"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:18000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:ZJH_COIN_18000_TAOBAO_URL                                        priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"33%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"33%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins6000"
                                  alipayProductId:@"zjh_coin_6000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:66000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:ZJH_COIN_66000_TAOBAO_URL
                                        priceList:priceList]];

    priceCN = [self cnPriceWithPrice:@"163" saving:@"50%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"50%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins20000"
                                  alipayProductId:@"zjh_coin_20000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:180000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:ZJH_COIN_180000_TAOBAO_URL                                        priceList:priceList]];

    
    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}

+ (void)createDiceCoinTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    PBIAPProductPrice *priceCN;
    PBIAPProductPrice *priceUS;
    NSArray *priceList;
    
    priceCN = [self cnPriceWithPrice:@"12" saving:nil];
    priceUS = [self usPriceWithPrice:@"1.99" saving:nil];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins1200"
                                  alipayProductId:@"dice_coin_1200"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:10000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DICE_COIN_10000_TAOBAO_URL
                                        priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"18" saving:@"15%"];
    priceUS = [self usPriceWithPrice:@"2.99" saving:@"15%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins2400"
                                  alipayProductId:@"dice_coin_2400"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:18000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DICE_COIN_18000_TAOBAO_URL
                                        priceList:priceList]];
    
    priceCN = [self cnPriceWithPrice:@"68" saving:@"33%"];
    priceUS = [self usPriceWithPrice:@"9.99" saving:@"33%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins6000"
                                  alipayProductId:@"dice_coin_6000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:66000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DICE_COIN_66000_TAOBAO_URL
                                        priceList:priceList]];

    priceCN = [self cnPriceWithPrice:@"163" saving:@"50%"];
    priceUS = [self usPriceWithPrice:@"24.99" saving:@"50%"];
    priceList = [NSArray arrayWithObjects:priceCN, priceUS, nil];
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins20000"
                                  alipayProductId:@"dice_coin_20000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:180000
                                       totalPrice:priceCN.price
                                           saving:priceCN.saving
                                        taobaoUrl:DICE_COIN_180000_TAOBAO_URL
                                        priceList:priceList]];

    PBIAPProductList_Builder *listBuilder = [[PBIAPProductList_Builder alloc] init];
    [listBuilder addAllProducts:mutableArray];
    PBIAPProductList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = [@"/Users/Linruin/gitdata/" stringByAppendingPathComponent:[IAPProductManager IAPProductFileName]];
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


+ (PBIAPProduct *)usProductWithType:(PBIAPProductType)type
                     appleProductId:(NSString *)appleProductId
                    alipayProductId:(NSString *)alipayProductId
                               name:(NSString *)name
                               desc:(NSString *)desc
                              count:(int)count
                         totalPrice:(NSString *)totalPrice
                             saving:(NSString *)saving
                          taobaoUrl:(NSString *)taobaoUrl
{
    PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setAlipayProductId:alipayProductId];
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
                    alipayProductId:(NSString *)alipayProductId
                               name:(NSString *)name
                               desc:(NSString *)desc
                              count:(int)count
                         totalPrice:(NSString *)totalPrice
                             saving:(NSString *)saving
                          taobaoUrl:(NSString *)taobaoUrl
                          priceList:(NSArray*)priceList
{
    PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setAlipayProductId:alipayProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"$"];
    [builder setCountry:@"US"];
    [builder setTaobaoUrl:taobaoUrl];
    [builder addAllPrices:priceList];
    
    return [builder build];
}


+ (PBIAPProduct *)productWithType:(PBIAPProductType)type
                   appleProductId:(NSString *)appleProductId
                  alipayProductId:(NSString *)alipayProductId
                             name:(NSString *)name
                             desc:(NSString *)desc
                            count:(int)count
                       totalPrice:(NSString *)totalPrice
                           saving:(NSString *)saving
                        taobaoUrl:(NSString *)taobaoUrl
{
    PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setAlipayProductId:alipayProductId];
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
                  alipayProductId:(NSString *)alipayProductId
                             name:(NSString *)name
                             desc:(NSString *)desc
                            count:(int)count
                       totalPrice:(NSString *)totalPrice
                           saving:(NSString *)saving
                        taobaoUrl:(NSString *)taobaoUrl
                        priceList:(NSArray *)priceList
{
    PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setAlipayProductId:alipayProductId];
    [builder setName:name];
    [builder setDesc:desc];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"￥"];
    [builder setCountry:@"CN"];
    [builder setTaobaoUrl:taobaoUrl];
    [builder addAllPrices:priceList];
    
    return [builder build];
}


+ (PBIAPProductPrice *)priceWithPrice:(NSString *)price
                   currency:(NSString *)currency
                    country:(NSString *)country
                     saving:(NSString *)saving
{
    PBIAPProductPrice_Builder *builder = [[[PBIAPProductPrice_Builder alloc] init] autorelease];
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
