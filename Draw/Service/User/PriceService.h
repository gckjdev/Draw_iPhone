//
//  PriceService.h
//  Draw
//
//  Created by  on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "PriceModel.h"
#import "PPTableViewController.h"
#import <StoreKit/StoreKit.h>

@interface PriceService : CommonService<SKProductsRequestDelegate>

+ (PriceService *)defaultService;
- (void)syncShoppingListAtBackground;

@end
