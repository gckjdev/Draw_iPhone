//
//  CommonItem.h
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "UserGameItemService.h"

@protocol ItemActionProtocol <NSObject>

- (int)itemId;

@end



//typedef void (^ConsumeItemResultHandler)(int resultCode, int itemId);

@interface CommonItem : NSObject
{
    
}
@property (assign, nonatomic) ConsumeItemResultHandler handler;

@end
