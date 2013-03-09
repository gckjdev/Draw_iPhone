//
//  UserItem.h
//  Draw
//
//  Created by 王 小涛 on 13-3-9.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@interface UserItem : NSObject

@property (retain, nonatomic) PBUserItem *pbUserItem;

+ (id)userItemFromPBUserItem:(PBUserItem *)pbUserItem;

- (void)setCount:(int)count;

@end
