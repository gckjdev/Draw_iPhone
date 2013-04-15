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

+ (void)createDrawIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_18"
                                  alipayProductId:@"draw_ingot_18"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:18
                                       totalPrice:@"18"
                                           saving:nil
                                        taobaoUrl:DRAW_INGOT_18_TAOBAO_URL]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_30"
                                  alipayProductId:@"draw_ingot_30"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:32
                                       totalPrice:@"30"
                                           saving:@"6%"
                                        taobaoUrl:DRAW_INGOT_32_TAOBAO_URL]];

    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_68"
                                  alipayProductId:@"draw_ingot_68"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:90
                                       totalPrice:@"68"
                                           saving:@"24%"
                                        taobaoUrl:DRAW_INGOT_90_TAOBAO_URL]];

    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_163"
                                  alipayProductId:@"draw_ingot_163"
                                             name:@"kIngot"
                                             desc:@"kIngot"
                                            count:250
                                       totalPrice:@"163"
                                           saving:@"35%"
                                        taobaoUrl:DRAW_INGOT_250_TAOBAO_URL]];

    
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
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                  appleProductId:@"com.orange.zjh.coins1200"
                                  alipayProductId:@"zjh_coin_1200"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                           count:10000
                                      totalPrice:@"12"
                                           saving:nil
                                        taobaoUrl:ZJH_COIN_10000_TAOBAO_URL]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins2400"
                                  alipayProductId:@"zjh_coin_2400"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:18000
                                       totalPrice:@"18"
                                           saving:@"15%"
                                        taobaoUrl:ZJH_COIN_18000_TAOBAO_URL]];

    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins6000"
                                  alipayProductId:@"zjh_coin_6000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:66000
                                       totalPrice:@"68"
                                           saving:@"33%"
                                        taobaoUrl:ZJH_COIN_66000_TAOBAO_URL]];

    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins20000"
                                  alipayProductId:@"zjh_coin_20000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:180000
                                       totalPrice:@"163"
                                           saving:@"50%"
                                        taobaoUrl:ZJH_COIN_180000_TAOBAO_URL]];

    
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
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins1200"
                                  alipayProductId:@"dice_coin_1200"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:10000
                                       totalPrice:@"12"
                                           saving:nil]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins2400"
                                  alipayProductId:@"dice_coin_2400"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:18000
                                       totalPrice:@"18"
                                           saving:@"15%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins6000"
                                  alipayProductId:@"dice_coin_6000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:66000
                                       totalPrice:@"68"
                                           saving:@"33%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.dice.coins20000"
                                  alipayProductId:@"dice_coin_20000"
                                             name:@"kCoin"
                                             desc:@"kCoin"
                                            count:180000
                                       totalPrice:@"163"
                                           saving:@"50%"]];
    
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


@end
