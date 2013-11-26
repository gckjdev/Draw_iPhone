//
//  GroupManager.m
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import "GroupManager.h"
#import "BBSPostCommand.h"

static GroupManager *_staticGroupManager = nil;

@interface GroupManager()

@end

@implementation GroupManager

- (void)dealloc
{
    PPRelease(_followedGroupIds);
//    PPRelease(_tempPostList);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.followedGroupIds = [NSMutableArray array];
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
    return @[@(GroupCreateTopic), @(GroupSearchGroup), @(GroupChat)];
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

@end
