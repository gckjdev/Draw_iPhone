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


/*****************************************************
 
 This Class is kept for legacy code
 
 
 ******************************************************/

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

// call this method for online play handling, when receiving items thrown from other users



@end
