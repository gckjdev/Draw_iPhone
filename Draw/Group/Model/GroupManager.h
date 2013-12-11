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
@property(nonatomic, assign) NSInteger commentBadge;
@property(nonatomic, assign) NSInteger requestBadge;
@property(nonatomic, assign) NSInteger noticeBadge;
@property(nonatomic, assign, readonly) NSInteger totalBadge;

@property(atomic, retain) NSMutableArray *tempMemberList;

+ (id)defaultManager;

+ (NSInteger)capacityForLevel:(NSInteger)level;
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level;

+ (NSArray *)defaultTypesInGroupHomeFooterForTab:(GroupTab)tab;
+ (NSArray *)defaultTypesInGroupTopicFooter:(PBGroup *)group;

- (BOOL)followedGroup:(NSString *)groupId;

+ (NSMutableArray *)getTopicCMDList:(PBBBSPost *)post inGroup:(PBGroup *)group;

- (void)collectGroup:(PBGroup *)group;
- (void)collectGroups:(NSArray *)groups;
- (PBGroup *)findGroupById:(NSString *)groupId;

- (void)updateBadges:(NSArray *)badges;

@end
