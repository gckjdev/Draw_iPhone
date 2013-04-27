//
//  SKProductManager.h
//  Draw
//
//  Created by 王 小涛 on 13-4-27.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProductManager : NSObject

@property (retain, nonatomic) NSArray *productList;

+ (id)defaultManager;
- (SKProduct *)productWithId:(NSString *)productId;


@end
