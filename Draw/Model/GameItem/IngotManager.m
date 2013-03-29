//
//  IngotManager.m
//  Draw
//
//  Created by 王 小涛 on 13-3-28.
//
//

#import "IngotManager.h"
#import "SynthesizeSingleton.h"

#define SALE_INGOT_FILE_WITHOUT_SUFFIX  @"sale_ingot"
#define SALE_INGOT_FILE_TYPE @"pb"
#define SALE_INGOT_FILE_VERSION @"1.0"

@interface IngotManager()

@end

@implementation IngotManager

SYNTHESIZE_SINGLETON_FOR_CLASS(IngotManager);

- (void)dealloc{
    [_ingotList release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:SALE_INGOT_FILE_WITHOUT_SUFFIX ofType:SALE_INGOT_FILE_TYPE];
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.ingotList = [[PBSaleIngotList parseFromData:data] ingotsList];
    }
    
    return self;
}

- (PBSaleIngot *)ingotWithProductId:(NSString *)productId
{
    for (PBSaleIngot *ingot in _ingotList) {
        if ([ingot.appleProductId isEqualToString:productId]) {
            return ingot;
        }
    }
    
    return nil;
}

+ (NSString *)saleIngotFileName
{
    return [[[[SALE_INGOT_FILE_WITHOUT_SUFFIX stringByAppendingString:@"_"] stringByAppendingString:[GameApp gameId]] stringByAppendingString:@"."] stringByAppendingString:[self saleIngotFileType]];
}

+ (NSString *)saleIngotFileBundlePath
{
    return [self saleIngotFileName];
}

+ (NSString *)saleIngotFileType
{
    return SALE_INGOT_FILE_TYPE;
}

+ (NSString *)saleIngotFileVersion
{
    return SALE_INGOT_FILE_VERSION;
}

@end
