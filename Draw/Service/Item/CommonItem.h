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

@class BlockArray;

@interface CommonItem : NSObject


@property (retain, nonatomic) BlockArray *blockArray;


@end