//
//  ItemService.h
//  Draw
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "ItemType.h"
#import "Feed.h"


@protocol ItemServiceDelegate <NSObject>

@optional
- (void)didUseItem:(ItemType)type 
      toTargetFeed:(Feed *)feed 
        resultCode:(NSInteger)resultCode;

@end

@interface ItemService : CommonService
{
    
}
+ (ItemService *)defaultService;

- (void)useItem:(ItemType)type 
   toTargetFeed:(Feed *)feed 
       delegate:(id<ItemServiceDelegate>)delegate;

@end
