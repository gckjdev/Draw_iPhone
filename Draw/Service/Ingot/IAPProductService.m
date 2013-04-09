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
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int index = 0 ; index < 4; index ++) {
        
        PBIAPProduct_Builder *builder = [[[PBIAPProduct_Builder alloc] init] autorelease];
        
        if (index == 0) {
            [builder setType:PBIAPProductTypeIapingot];
            [builder setAppleProductId:@"com.orange.draw.ingot_18"];
            [builder setCount:18];
            [builder setTotalPrice:@"18"];
        } else if (index == 1){
            [builder setType:PBIAPProductTypeIapingot];
            [builder setAppleProductId:@"com.orange.draw.ingot_30"];
            [builder setCount:32];
            [builder setTotalPrice:@"30"];
            [builder setSaving:@"6%"];
        } else if (index == 2){
            [builder setType:PBIAPProductTypeIapingot];
            [builder setAppleProductId:@"com.orange.draw.ingot_68"];
            [builder setCount:90];
            [builder setTotalPrice:@"68"];
            [builder setSaving:@"24%"];
        } else if (index == 3){
            [builder setType:PBIAPProductTypeIapingot];
            [builder setAppleProductId:@"com.orange.draw.ingot_163"];
            [builder setCount:250];
            [builder setTotalPrice:@"163"];
            [builder setSaving:@"35%"];
        }
        
        [builder setCurrency:@"￥"];
        [builder setCountry:@"CN"];
        
        PBIAPProduct *saleIngot = [builder build];
        [mutableArray addObject:saleIngot];
    }
    
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

@end
