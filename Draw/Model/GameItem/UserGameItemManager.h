//
//  UserGameItemManager.h
//  Draw
//
//  Created by 王 小涛 on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@interface UserGameItemManager : NSObject

+ (UserGameItemManager *)defaultManager;

- (void)setUserItemList:(NSArray *)itemsList;

- (PBUserItem *)userItemWithItemId:(int)itemId;
- (int)countOfItem:(int)itemId;
- (BOOL)hasItem:(int)itemId;


@end
