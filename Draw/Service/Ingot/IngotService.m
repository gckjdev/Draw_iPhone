//
//  IngotService.m
//  Draw
//
//  Created by 王 小涛 on 13-3-7.
//
//

#import "IngotService.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "GameBasic.pb.h"

#define INGOT_FILE_NAME  @"sale_ingot.pb"
#define INGOT_FILE_VERSION  @"1.0"

@implementation IngotService

SYNTHESIZE_SINGLETON_FOR_CLASS(IngotService);

- (void)getIngotsList:(GetIngotsListResultHandler)handler
{
    //load data
    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:INGOT_FILE_NAME type:SMART_UPDATE_DATA_TYPE_PB bundlePath:INGOT_FILE_NAME initDataVersion:INGOT_FILE_VERSION];
    
    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *itemsList = [[PBSaleIngotList parseFromData:data] ingotsList];
        handler(YES, itemsList);
        [smartData release];
    } failureBlock:^(NSError *error) {
        PPDebug(@"getIngotsList failure error=%@", [error description]);
        handler(NO, nil);
        [smartData release];
    }];
}


//************************************************************
//message PBSaleIngot{
//    required int32 count = 1;                 // 个数
//    optional string totalPrice = 2;           // 总价格
//    optional string currency = 3;             // 货币符号
//    optional string country = 5;              // 适应国家，中国"CN"
//}


+ (void)createTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int index = 0 ; index < 6; index ++) {
        
        PBSaleIngot_Builder *saleIngot_Builder = [[PBSaleIngot_Builder alloc] init];
        
        if (index == 0) {
            [saleIngot_Builder setCount:6];
            [saleIngot_Builder setTotalPrice:@"6"];
            [saleIngot_Builder setCurrency:@"￥"];
        } else if (index == 1){
            [saleIngot_Builder setCount:13];
            [saleIngot_Builder setTotalPrice:@"12"];
            [saleIngot_Builder setCurrency:@"￥"];
        } else if (index == 2){
            [saleIngot_Builder setCount:20];
            [saleIngot_Builder setTotalPrice:@"18"];
            [saleIngot_Builder setCurrency:@"￥"];
        } else if (index == 3){
            [saleIngot_Builder setCount:65];
            [saleIngot_Builder setTotalPrice:@"60"];
            [saleIngot_Builder setCurrency:@"￥"];
        } else if (index == 4){
            [saleIngot_Builder setCount:132];
            [saleIngot_Builder setTotalPrice:@"120"];
            [saleIngot_Builder setCurrency:@"￥"];
        } else if (index == 5){
            [saleIngot_Builder setCount:276];
            [saleIngot_Builder setTotalPrice:@"240"];
            [saleIngot_Builder setCurrency:@"￥"];
        }
    
        PBSaleIngot *saleIngot = [saleIngot_Builder build];
        [saleIngot_Builder release];
        [mutableArray addObject:saleIngot];
    }
    
    PBSaleIngotList_Builder *listBuilder = [[PBSaleIngotList_Builder alloc] init];
    [listBuilder addAllIngots:mutableArray];
    PBSaleIngotList *list = [listBuilder build];
    
    //write to file
    NSString *filePath = @"/Users/gckj/shopItem/sale_ingot.pb";
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


@end
