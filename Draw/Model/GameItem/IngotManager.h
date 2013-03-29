//
//  IngotManager.h
//  Draw
//
//  Created by 王 小涛 on 13-3-28.
//
//

#import <Foundation/Foundation.h>



@interface IngotManager : NSObject

@property (retain, nonatomic) NSArray *ingotList;

+ (IngotManager *)defaultManager;
+ (NSString *)saleIngotFileName;
+ (NSString *)saleIngotFileBundlePath;
+ (NSString *)saleIngotFileVersion;

- (PBSaleIngot *)ingotWithProductId:(NSString *)productId;


@end
