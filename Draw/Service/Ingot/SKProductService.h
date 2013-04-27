//
//  SKProductService.h
//  Draw
//
//  Created by 王 小涛 on 13-4-27.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProductService : NSObject<SKProductsRequestDelegate>

+ (id)defaultService;
- (void)syncDataFromIAPService;

@end
