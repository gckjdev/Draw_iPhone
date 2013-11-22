//
//  GroupManager.h
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import <Foundation/Foundation.h>
#import "GroupUIManager.h"
#import "GroupPermission.h"



@interface GroupManager : NSObject
@property(nonatomic, retain)NSMutableArray *followedGroupIds;

+ (id)defaultManager;

+ (NSInteger)capacityForLevel:(NSInteger)level;
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level;

+ (NSArray *)defaultTypesInGroupHomeFooterForTab:(GroupTab)tab;
+ (NSArray *)defaultTypesInGroupTopicFooter:(PBGroup *)group;

- (BOOL)followedGroup:(NSString *)groupId;



@end
