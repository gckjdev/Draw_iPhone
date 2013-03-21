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

- (PBSaleIngot*)findSaleIngoWithAppleProductId:(NSString*)appleProductId
{
    return nil;
}

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
        NSData *data = [NSData dataWithContentsOfFile:smartData.dataFilePath];
        NSArray *itemsList = [[PBSaleIngotList parseFromData:data] ingotsList];
        handler(NO, itemsList);
        [smartData release];
    }];
}


//************************************************************
//"com.orange.draw.coins20000",
//"com.orange.draw.coins400",
//"com.orange.draw.coins2400",
//"com.orange.draw.coins6000"

+ (void)createTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int index = 0 ; index < 4; index ++) {
        
        PBSaleIngot_Builder *saleIngot_Builder = [[PBSaleIngot_Builder alloc] init];
        
        if (index == 0) {
            [saleIngot_Builder setCount:18];
            [saleIngot_Builder setTotalPrice:@"18"];
            //[saleIngot_Builder setSaving:nil];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.coins400"];
        } else if (index == 1){
            [saleIngot_Builder setCount:32];
            [saleIngot_Builder setTotalPrice:@"30"];
            [saleIngot_Builder setSaving:@"6%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.coins2400"];
        } else if (index == 2){
            [saleIngot_Builder setCount:90];
            [saleIngot_Builder setTotalPrice:@"68"];
            [saleIngot_Builder setSaving:@"24%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.coins6000"];
        } else if (index == 3){
            [saleIngot_Builder setCount:250];
            [saleIngot_Builder setTotalPrice:@"163"];
            [saleIngot_Builder setSaving:@"35%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.coins20000"];
        }
        
        [saleIngot_Builder setCurrency:@"￥"];
        [saleIngot_Builder setCountry:@"CN"];
        
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
