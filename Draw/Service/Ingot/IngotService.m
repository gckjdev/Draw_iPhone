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
#import "IngotManager.h"
#import "BlockArray.h"

@interface IngotService()
@property (retain, nonatomic) BlockArray *blockArray;

@end

@implementation IngotService

SYNTHESIZE_SINGLETON_FOR_CLASS(IngotService);

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

- (void)syncData:(GetIngotsListResultHandler)handler
{
    GetIngotsListResultHandler tempHandler = (GetIngotsListResultHandler)[_blockArray copyBlock:handler];

    PPSmartUpdateData *smartData = [[PPSmartUpdateData alloc] initWithName:[IngotManager saleIngotFileName] type:SMART_UPDATE_DATA_TYPE_PB bundlePath:[IngotManager saleIngotFileBundlePath] initDataVersion:[IngotManager saleIngotFileVersion]];
    
    __block typeof(self) bself = self;

    [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *ingotList = [[PBSaleIngotList parseFromData:data] ingotsList];
        [[IngotManager defaultManager] setIngotList:ingotList];
        
        EXECUTE_BLOCK(tempHandler, YES, ingotList);
        [bself.blockArray releaseBlock:tempHandler];
        [smartData release];
    } failureBlock:^(NSError *error) {
        PPDebug(@"getIngotsList failure error=%@", [error description]);
        NSData *data = [NSData dataWithContentsOfFile:smartData.dataFilePath];
        NSArray *ingotList = [[PBSaleIngotList parseFromData:data] ingotsList];
        [[IngotManager defaultManager] setIngotList:ingotList];
        EXECUTE_BLOCK(tempHandler, NO, ingotList);
        [bself.blockArray releaseBlock:tempHandler];
        [smartData release];
    }];
}

+ (void)createTestDataFile
{
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (int index = 0 ; index < 4; index ++) {
        
        PBSaleIngot_Builder *saleIngot_Builder = [[PBSaleIngot_Builder alloc] init];
        
        if (index == 0) {
            [saleIngot_Builder setCount:18];
            [saleIngot_Builder setTotalPrice:@"18"];
            //[saleIngot_Builder setSaving:nil];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.ingot_18"];
        } else if (index == 1){
            [saleIngot_Builder setCount:32];
            [saleIngot_Builder setTotalPrice:@"30"];
            [saleIngot_Builder setSaving:@"6%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.ingot_30"];
        } else if (index == 2){
            [saleIngot_Builder setCount:90];
            [saleIngot_Builder setTotalPrice:@"68"];
            [saleIngot_Builder setSaving:@"24%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.ingot_68"];
        } else if (index == 3){
            [saleIngot_Builder setCount:250];
            [saleIngot_Builder setTotalPrice:@"163"];
            [saleIngot_Builder setSaving:@"35%"];
            [saleIngot_Builder setAppleProductId:@"com.orange.draw.ingot_163"];
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
    NSString *filePath = @"/Users/Linruin/gitdata/sale_ingot.pb";
    if (![[list data] writeToFile:filePath atomically:YES]) {
        PPDebug(@"<createTestDataFile> error");
    } else {
        PPDebug(@"<createTestDataFile> succ");
    }
    
    [listBuilder release];
}


@end
