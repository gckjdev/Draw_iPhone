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
#import "GroupModelExt.h"


@interface GroupManager : NSObject
@property(nonatomic, retain)NSMutableArray *followedGroupIds;
@property(nonatomic, assign) NSInteger commentBadge;
@property(nonatomic, assign) NSInteger requestBadge;
@property(nonatomic, assign) NSInteger noticeBadge;
@property(nonatomic, assign, readonly) NSInteger totalBadge;

@property(atomic, retain) NSMutableArray *tempMemberList;
@property(nonatomic, retain) PBGroup *sharedGroup;

+ (id)defaultManager;

+ (NSInteger)capacityForLevel:(NSInteger)level;
+ (NSInteger)monthlyFeeForLevel:(NSInteger)level;

+ (NSArray *)defaultTypesInGroupHomeFooterForTab:(GroupTab)tab;
+ (NSArray *)defaultTypesInGroupTopicFooter:(PBGroup *)group;

- (BOOL)followedGroup:(NSString *)groupId;

+ (NSMutableArray *)getTopicCMDList:(PBBBSPost *)post inGroup:(NSString *)groupId;

//- (void)collectGroup:(PBGroup *)group;
//- (void)collectGroups:(NSArray *)groups;
//- (PBGroup *)findGroupById:(NSString *)groupId;

- (void)updateBadges:(NSArray *)badges;

//change group admin list, return new group.


+ (PBGroup *)didSetUser:(PBGameUser *)user
         asAdminInGroup:(PBGroup *)group;

+ (void)didUpdateUser:(PBGameUser *)user
          fromTitleId:(NSInteger)fromTitleId
            toTitleId:(NSInteger)toTitleId;

+ (PBGroup *)didRemoveUser:(PBGameUser *)user
          fromAdminInGroup:(PBGroup *)group;

+ (void)didRemoveUser:(PBGameUser *)user
          fromTitleId:(NSInteger)titleId;

+ (void)didUserQuited:(PBGameUser *)user;


+ (void)didAddedGroupTitle:(NSString *)groupId
                     title:(NSString *)title
                   titleId:(NSInteger)titleId;


+ (void)didUpdatedGroupTitle:(NSString *)groupId
                       title:(NSString *)title
                     titleId:(NSInteger)titleId;

+ (void)didDeletedGroupTitle:(NSString *)groupId
                     titleId:(NSInteger)titleId;


+ (PBGroup *)updateGroup:(PBGroup *)group medalImageURL:(NSString *)url;
+ (PBGroup *)updateGroup:(PBGroup *)group BGImageURL:(NSString *)url;

+ (BOOL)isUser:(PBGameUser *)user adminOrCreatorInGroup:(PBGroup *)group;
+ (BOOL)isMeAdminOrCreatorInSharedGroup;
+ (NSInteger)genTitleId;

+ (NSArray *)candidateTitlesForChangingTitle:(PBGroupTitle *)title;


- (NSMutableArray *)membersForShow;
- (NSInteger)customTitleCount;

- (NSString *)joindeGroupIdForName:(NSString *)name;
- (NSArray *)joinedGroupNames;

@end
