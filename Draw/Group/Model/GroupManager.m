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
//    PPRelease(_tempPostList);
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

+ (NSMutableArray *)getTopicCMDList:(PBBBSPost *)post inGroup:(PBGroup *)group
{
    GroupPermissionManager *pm = [GroupPermissionManager myManagerWithGroup:group];
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

@end
