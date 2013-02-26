//
//  GameItemService.h
//  Draw
//
//  Created by qqn_pipi on 13-2-22.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@protocol GameItmeServiceDelegate <NSObject>

- (void)didGetItem:(int)resultCode item:(PBGameItem *)item;
- (void)didGetItemList:(int)resultCode itemList:(NSArray *)itemList;

@end

@interface GameItemService : NSObject

- (void)getItem:(int)itemId;
- (void)getItemList;

@end
