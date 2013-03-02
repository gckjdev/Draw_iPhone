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

#define ITEMS_FILE @"items.pb"
#define BUNDLE_PATH @"items.pb"
#define ITEMS_FILE_VERSION @"1.0"

@interface GameItemService ()

@property (retain, nonatomic) NSArray *itemsList;

@end

@implementation GameItemService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameItemService);

- (void)dealloc
{
    [_itemsList release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        //load data
        PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:ITEMS_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:ITEMS_FILE_VERSION] autorelease];
        
        [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
            NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
            self.itemsList = [[PBGameItemList parseFromData:data] itemsListList];
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    
    return self;
}


- (void)getItem:(int)itemId
{
}

- (void)getItemList
{
    
}




@end
