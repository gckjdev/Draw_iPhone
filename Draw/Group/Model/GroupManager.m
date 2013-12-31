//
//  GroupManager.m
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import "GroupManager.h"
#import "BBSPostCommand.h"
#import "Group.pb.h"


static GroupManager *_staticGroupManager = nil;

@interface GroupManager()

//uid : dict
@property (nonatomic, retain)NSMutableDictionary *collectionDict;

@end



@implementation GroupManager

- (void)dealloc
{
    PPRelease(_followedGroupIds);
    PPRelease(_collectionDict);
    PPRelease(_tempMemberList);
    PPRelease(_sharedGroup);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.followedGroupIds = [NSMutableArray array];
        self.collectionDict = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (id)defaultManager
{
    if (_staticGroupManager == nil) {
        _staticGroupManager = [[GroupManager alloc] init];
    }
    return _staticGroupManager;
}

+ (NSInteger)capacityForLevel:(NSInteger)level
{
    return level * 10;
}

+ (NSInteger)monthlyFeeForLevel:(NSInteger)level
{
    return level * 100;
}

- (BOOL)followedGroup:(NSString *)groupId
{
    return [_followedGroupIds containsObject:groupId];
}

+ (BOOL)isGroupTab:(GroupTab)tab
{
    NSArray *tabs = @[@(GroupTabGroup),
                      @(GroupTabGroupFollow),
                      @(GroupTabGroupBalance),
                      @(GroupTabGroupActive),
                      @(GroupTabGroupFame),
                      ];
    return [tabs containsObject:@(tab)];
    
}

+ (NSArray *)defaultTypesInGroupHomeFooterForTab:(GroupTab)tab
{
    NSMutableArray *array = [NSMutableArray array];
    if ([GroupPermissionManager canCreateGroup]) {
        [array addObject:@(GroupCreateGroup)];
    }
    [array addObjectsFromArray:@[@(GroupSearchGroup), @(GroupChat), @(GroupAtMe)]];
    return array;
}


+ (NSArray *)defaultTypesInGroupTopicFooter:(PBGroup *)group
{
    //TODO add quit type
    return @[@(GroupCreateTopic), @(GroupSearchTopic), @(GroupChat)];
}

+ (NSMutableArray *)getTopicCMDList:(PBBBSPost *)post inGroup:(NSString *)groupId
{
    GroupPermissionManager *pm = [GroupPermissionManager myManagerWithGroupId:groupId];
    NSMutableArray *list = [NSMutableArray array];
    if ([pm canCreateTopic]) {
        BBSPostReplyCommand *rc = [[[BBSPostReplyCommand alloc] initWithPost:post controller:nil] autorelease];
        [list addObject:rc];
        BBSPostSupportCommand *sc = [[[BBSPostSupportCommand alloc] initWithPost:post controller:nil] autorelease];
        [list addObject:sc];
    }
    if ([pm canDeleteTopic:post]) {
        BBSPostDeleteCommand *dc = [[[BBSPostDeleteCommand alloc] initWithPost:post controller:nil] autorelease];
        [list addObject:dc];
    }
    if ([pm canTopTopic]) {
        BBSPostTopCommand *tc = [[[BBSPostTopCommand alloc] initWithPost:post controller:nil] autorelease];
        [list addObject:tc];
    }
    
    if ([pm canMarkTopic]) {
        BBSPostMarkCommand *tc = [[[BBSPostMarkCommand alloc] initWithPost:post controller:nil] autorelease];
        [list addObject:tc];
    }

    return list;
}

/*
- (void)collectGroup:(PBGroup *)group
{
    //only collect the group having relation with current user.
    if (group.hasRelation) {
        NSString *userId = [[UserManager defaultManager] userId];

        NSMutableDictionary *cd = [self.collectionDict objectForKey:userId];
        if (cd == nil) {
            cd = [NSMutableDictionary dictionary];
            [self.collectionDict setObject:cd forKey:userId];
        }

        [cd setObject:group forKey:group.groupId];
        PPDebug(@"<collectGroup> group id = %@, name = %@", group.groupId, group.name);
    }
}

- (PBGroup *)findGroupById:(NSString *)groupId
{
    PBGroup *group = [self.collectionDict objectForKey:groupId];
    if (!group) {
        PPDebug(@"<findGroupById> can't find group, id = %@", groupId);
    }
    return group;
}

- (void)collectGroups:(NSArray *)groups
{
    for (PBGroup *group in groups) {
        [self collectGroup:group];
    }
}
 */

enum{
    BADGE_COMMENT = 1,
    BADGE_REQUEST = 2,
    BADGE_NOTICE = 3,
};

- (NSInteger)totalBadge
{
    return _noticeBadge + _commentBadge + _requestBadge;
}

- (void)updateBadges:(NSArray *)badges
{
    self.noticeBadge = self.commentBadge = self.requestBadge = 0;
    for (PBIntKeyIntValue *kv in badges) {
        switch (kv.key) {
            case BADGE_COMMENT:
                self.commentBadge = kv.value;
                break;
            case BADGE_REQUEST:
                self.requestBadge = kv.value;
                break;
            case BADGE_NOTICE:
                self.noticeBadge = kv.value;
                break;
            default:
                break;
        }
    }
}

+ (PBGroupUsersByTitle *)usersByTitleForTitleId:(NSInteger)titleId
{
    NSMutableArray *members = [[GroupManager defaultManager] tempMemberList];
    for (PBGroupUsersByTitle *usersByTitle in members) {
        if (usersByTitle.title.titleId == titleId) {
            return usersByTitle;
        }
    }
    return nil;
}

+ (void)updateMember:(PBGameUser *)member titleId:(NSInteger)titleId isRemove:(BOOL)isRemove
{
    PBGroupUsersByTitle *title = [self usersByTitleForTitleId:titleId];
    if (title) {
        PBGroupUsersByTitle_Builder *builder = [PBGroupUsersByTitle builderWithPrototype:title];
        NSMutableArray *userList = [NSMutableArray arrayWithArray:title.usersList];
        [builder clearUsersList];
        if (isRemove) {
            [userList removeObject:member];
        }else{
            [userList addObject:member];
        }
        [builder addAllUsers:userList];
        PBGroupUsersByTitle *nt = [builder build];
        
        NSMutableArray *members = [[GroupManager defaultManager] tempMemberList];
        NSInteger index = [members indexOfObject:title];
        [members replaceObjectAtIndex:index withObject:nt];
    }
}


+ (PBGroup *)didSetUser:(PBGameUser *)user
         asAdminInGroup:(PBGroup *)group
{
    PBGroup_Builder *builder = [PBGroup builderWithPrototype:group];
    [builder addAdmins:user];    
    group = [builder build];
    return group;
}

+ (PBGroup *)didRemoveUser:(PBGameUser *)user
          fromAdminInGroup:(PBGroup *)group;
{
    PBGroup_Builder *builder = [PBGroup builderWithPrototype:group];
    
    
    NSMutableArray *admins = [NSMutableArray arrayWithArray:group.adminsList];
    [builder clearAdminsList];
    [admins removeObject:user];
    [builder addAllAdmins:admins];
    
    group = [builder build];
    return group;
    
}

+ (void)didUpdateUser:(PBGameUser *)user
          fromTitleId:(NSInteger)fromTitleId
            toTitleId:(NSInteger)toTitleId
{
    if (fromTitleId == toTitleId) {
        return;
    }
    [self updateMember:user titleId:fromTitleId isRemove:YES];
    [self updateMember:user titleId:toTitleId isRemove:NO];
    
}


+ (void)didRemoveUser:(PBGameUser *)user
          fromTitleId:(NSInteger)titleId
{
    if (titleId != GroupRoleAdmin) {
        [self updateMember:user titleId:titleId isRemove:YES];
    }
}

+ (PBGroupTitle *)titleForUser:(PBGameUser *)user
{
    for (PBGroupUsersByTitle *usersByTitle in [[self defaultManager] tempMemberList]) {
        if ([usersByTitle.usersList containsObject:user]) {
            return usersByTitle.title;
        }
    }
    return nil;
}


+ (void)didUserQuited:(PBGameUser *)user
{
    PBGroup *group = [[self defaultManager] sharedGroup];
    if ([[group guestsList] containsObject:user]) {
        [self didRemoveUser:user fromTitleId:GroupRoleGuest];
        return;
    }
    if ([[group adminsList] containsObject:user]) {
        [self didRemoveUser:user fromAdminInGroup:group];
    }else{
        PBGroupTitle *title = [self titleForUser:user];
        if (title) {
            [self didRemoveUser:user fromTitleId:title.titleId];
        }
    }
}

+ (PBGroupTitle *)createGroupTitle:(NSString *)title
                           titleId:(NSInteger)titleId
{
    PBGroupTitle_Builder *titleBuilder = [[PBGroupTitle_Builder alloc] init];
    [titleBuilder setTitle:title];
    [titleBuilder setTitleId:titleId];
    PBGroupTitle *t = [titleBuilder build];
    [titleBuilder release];
    return t;

}

+ (void)didAddedGroupTitle:(NSString *)groupId
                     title:(NSString *)title
                   titleId:(NSInteger)titleId
{
    PBGroupUsersByTitle_Builder *builder = [[PBGroupUsersByTitle_Builder alloc] init];

    PBGroupTitle_Builder *titleBuilder = [[PBGroupTitle_Builder alloc] init];
    PBGroupTitle *t = [self createGroupTitle:title titleId:titleId];
    [builder setTitle:t];
    
    PBGroupUsersByTitle *ut = [builder build];
    [builder release];
    
    [[[GroupManager defaultManager] tempMemberList] addObject:ut];
}
+ (PBGroup *)updateGroup:(PBGroup *)group medalImageURL:(NSString *)url{
    PBGroup_Builder *builder = [PBGroup builderWithPrototype:group];
    [builder setMedalImage:url];
    return [builder build];
}
+ (PBGroup *)updateGroup:(PBGroup *)group BGImageURL:(NSString *)url
{
    PBGroup_Builder *builder = [PBGroup builderWithPrototype:group];
    [builder setBgImage:url];
    return [builder build];
}


+ (void)didDeletedGroupTitle:(NSString *)groupId
                     titleId:(NSInteger)titleId
{
    NSMutableArray *members = [[GroupManager defaultManager] tempMemberList];
    PBGroupUsersByTitle *gt = [self usersByTitleForTitleId:titleId];
    [members removeObject:gt];
}

+ (void)didUpdatedGroupTitle:(NSString *)groupId
                       title:(NSString *)title
                     titleId:(NSInteger)titleId
{
    NSMutableArray *members = [[GroupManager defaultManager] tempMemberList];
    PBGroupUsersByTitle *gt = [self usersByTitleForTitleId:titleId];
    if (gt) {
        PBGroupUsersByTitle_Builder *builder = [PBGroupUsersByTitle builderWithPrototype:gt];
        PBGroupTitle *t = [self createGroupTitle:title titleId:titleId];
        [builder setTitle:t];
        PBGroupUsersByTitle *ngt = [builder build];
        NSUInteger index = [members indexOfObject:gt];
        if (index != NSNotFound && !!ngt) {
            [members replaceObjectAtIndex:index withObject:ngt];
        }
    }
}


+ (BOOL)isUser:(PBGameUser *)user adminOrCreatorInGroup:(PBGroup *)group
{
    if ([group.creator isEqual:user]) {
        return YES;
    }
    if ([group.adminsList containsObject:user]){
        return YES;
    }
    return NO;        
}

+ (BOOL)isMeAdminOrCreatorInSharedGroup
{
    PBGroup *group = [[self defaultManager] sharedGroup];
    return [self isUser:[[UserManager defaultManager] pbUser] adminOrCreatorInGroup:group];
}

+ (NSInteger)genTitleId
{
    NSArray *members = [[self defaultManager] tempMemberList];
    NSInteger titleId = CUSTOM_TITLE_START;
    for (PBGroupUsersByTitle *ut in members) {
        titleId = MAX(titleId, ut.title.titleId);
    }
    titleId += 1;
    return titleId;
}

+ (NSArray *)candidateTitlesForChangingTitle:(PBGroupTitle *)title
{
    NSInteger titleId = title.titleId;
    NSArray *members = [[self defaultManager] tempMemberList];
    NSMutableArray *ret = [NSMutableArray array];
    for (PBGroupUsersByTitle *ut in members) {
        if (titleId != ut.title.titleId) {
            [ret addObject:ut.title];
        }
    }
    return ret;
}

- (NSMutableArray *)membersForShow
{
    NSMutableArray *list = [NSMutableArray array];
    for (PBGroupUsersByTitle *title in self.tempMemberList) {
        if ([title.usersList count] > 0) {
            [list addObject:title];
        }
    }
    return list;
}

- (NSString *)joindeGroupIdForName:(NSString *)name
{
    NSArray * list = [GroupPermissionManager groupRoles];
    for (PBGroupUserRole *role in list) {
        if([role.groupName isEqualToString:name]){
            return role.groupId;
        }
    }
    return nil;
}

- (NSArray *)joinedGroupNames
{
    NSArray * list = [GroupPermissionManager groupRoles];
    NSMutableArray *names = [NSMutableArray array];
    NSArray *intRoles = @[@(GroupRoleAdmin), @(GroupRoleCreator),
                          @(GroupRoleGuest), @(GroupRoleMember)
                          ];
    for (PBGroupUserRole *role in list) {
        if ([intRoles containsObject:@(role.role)]) {
            if([role.groupName length] != 0){
                [names addObject:role.groupName];
            }
        }
    }
    return names;
}

- (NSString *)groupNameById:(NSString*)groupId
{
    if (groupId == nil){
        return @"";
    }
    
    NSArray * list = [GroupPermissionManager groupRoles];
    for (PBGroupUserRole *role in list) {
        if([role.groupId isEqualToString:groupId]){
            return role.groupName;
        }
    }
    return @"";
}

- (NSString *)userCurrentGroupName
{
    return [self groupNameById:[self userCurrentGroupId]];
}

- (NSString *)userCurrentGroupId
{
    NSArray * list = [GroupPermissionManager groupRoles];
    
    NSArray *intRoles = @[@(GroupRoleCreator),
                          @(GroupRoleAdmin),
                          @(GroupRoleMember)
                          ];
    
    for (NSNumber* roleType in intRoles){
        // 按照顺序，优先匹配权限
        for (PBGroupUserRole *role in list) {
            if (role.role == [roleType intValue]) {
                PPDebug(@"current user groupId is %@ name %@", role.groupId, role.groupName);
                return role.groupId;
            }
        }
    }

    PPDebug(@"current user groupId not found");
    return nil;
}

- (PBGroup*)userCurrentGroup
{
    NSString* groupId = [self userCurrentGroupId];
    NSString* groupName = [self userCurrentGroupName];
    
    if (groupId == nil || groupName == nil)
        return nil;

    PBGroup_Builder* builder = [PBGroup builder];
    [builder setGroupId:groupId];
    [builder setName:groupName];
    PBGroup* group = [builder build];
    return group;
}

@end
