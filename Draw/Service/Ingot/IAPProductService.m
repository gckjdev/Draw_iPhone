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


+ (void)createIngotTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_18"
                                            count:18
                                       totalPrice:@"18"
                                           saving:nil]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_30"
                                            count:32
                                       totalPrice:@"30"
                                           saving:@"6%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_68"
                                            count:90
                                       totalPrice:@"68"
                                           saving:@"24%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapingot
                                   appleProductId:@"com.orange.draw.ingot_163"
                                            count:250
                                       totalPrice:@"163"
                                           saving:@"35%"]];
    
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


+ (void)createCoinTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                  appleProductId:@"com.orange.zjh.coins1200"
                                           count:10000
                                      totalPrice:@"12"
                                           saving:nil]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins2400"
                                            count:18000
                                       totalPrice:@"18"
                                           saving:@"15%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins6000"
                                            count:66000
                                       totalPrice:@"68"
                                           saving:@"33%"]];
    
    [mutableArray addObject:[self productWithType:PBIAPProductTypeIapcoin
                                   appleProductId:@"com.orange.zjh.coins20000"
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
                            count:(int)count
                       totalPrice:(NSString *)totalPrice
                           saving:(NSString *)saving
{
    PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setAppleProductId:appleProductId];
    [builder setCount:count];
    [builder setTotalPrice:totalPrice];
    [builder setSaving:saving];
    [builder setCurrency:@"￥"];
    [builder setCountry:@"CN"];
    
    return [builder build];
}


@end