//
//  GroupService.m
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "GroupService.h"
#import "PPGameNetworkRequest.h"
#import "PPNetworkConstants.h"
#import "CommonOpusDetailController.h"
#import "DrawError.h"
#import "PPConfigManager.h"


#define GROUP_HOST     [PPConfigManager getGroupServerURL]



typedef void (^ PBResponseResultBlock) (DataQueryResponse *response, NSError* error);

static GroupService *_staticGroupService = nil;

@interface GroupService()
@property(assign, nonatomic)GroupManager *groupManager;
@end

@implementation GroupService

- (id)init
{
    self = [super init];
    if (self) {
        self.groupManager = [GroupManager defaultManager];
    }
    return self;
}

+ (GroupService *)defaultService
{
    if (_staticGroupService == nil) {
        _staticGroupService = [[GroupService alloc] init];        
    }
    return _staticGroupService;
}

- (void)loadPBData:(NSString *)method
      parameters:(NSDictionary *)parameters
        callback:(PBResponseResultBlock)callback
{    
    if(self.isTestMode){
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:GROUP_HOST
                                     method:method
                                     parameters:parameters
                                     returnPB:YES
                                     returnJSONArray:NO];
        NSError *error = DRAW_ERROR(output.pbResponse.resultCode);
        if (error) {
            [DrawError postError:error];
        }
        EXECUTE_BLOCK(callback, output.pbResponse, error);
    }else{
        dispatch_async(workingQueue, ^{
            GameNetworkOutput* output = [PPGameNetworkRequest
                                         sendGetRequestWithBaseURL:GROUP_HOST
                                         method:method
                                         parameters:parameters
                                         returnPB:YES
                                         returnJSONArray:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = DRAW_ERROR(output.pbResponse.resultCode);
                if (error) {
                    PPDebug(@"<GroupService> load data error = %@", error);
                    [DrawError postError:error];
                }

                if ([output.pbResponse hasGroup]) {
                    [[GroupManager defaultManager] collectGroup:output.pbResponse.group];
                }
                if ([output.pbResponse.groupListList count] != 0) {
                    [[GroupManager defaultManager] collectGroups:output.pbResponse.groupListList];
                }
                
                EXECUTE_BLOCK(callback, output.pbResponse, error);
            });
        });
    }
}

//checked
- (void)createGroup:(NSString *)name
             level:(NSInteger)level
          callback:(GroupResultBlock)callback
{
    NSDictionary *paras = @{
                            PARA_NAME:name,
                            PARA_LEVEL: @(level)
                            };
    
    [self loadPBData:METHOD_CREATE_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
    {
        EXECUTE_BLOCK(callback, error?nil:response.group, error);
    }];
}

//checked
- (void)getGroup:(NSString *)groupId
        callback:(GroupResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_GET_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error ? nil : response.group, error);
     }];
}


//checked
- (void)joinGroup:(NSString *)groupId
          message:(NSString *)message
         callback:(SimpleResultBlock)callback;
{
    
    message = (message ? message : @"");
    NSDictionary *paras = @{PARA_GROUPID:groupId, PARA_MESSAGETEXT:message};
    
    [self loadPBData:METHOD_JOIN_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}


- (void)getGroupsWithType:(GetGroupListType)type
                   offset:(NSInteger)offset
                    limit:(NSInteger)limit
                 callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_OFFSET:@(offset), PARA_LIMIT:@(limit), PARA_TYPE:@(type)};

    
    [self loadPBData:METHOD_GET_GROUPS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, response.groupListList, error);
    }];

}

- (void)searchGroupsByKeyword:(NSString *)keyword
                       offset:(NSInteger)offset
                        limit:(NSInteger)limit
                     callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_OFFSET:@(offset), PARA_LIMIT:@(limit), PARA_KEYWORD:keyword};
    
    
    [self loadPBData:METHOD_SEARCH_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, response.groupListList, error);
            }];
}


#define HANDLE_TYPE_ACCEPT 1
#define HANDLE_TYPE_REJECT 2


- (void)handleUserRequestNotice:(PBGroupNotice *)notice
                         accept:(BOOL)accept
                         reason:(NSString *)reason
                       callback:(SimpleResultBlock)callback
{
    NSInteger type = accept?HANDLE_TYPE_ACCEPT:HANDLE_TYPE_REJECT;
    NSMutableDictionary *paras = [NSMutableDictionary dictionary];
    [paras setObject:notice.noticeId forKey:PARA_NOTICEID];
    [paras setObject:@(type) forKey:PARA_TYPE];
    

    if (reason) {
        [paras setObject:reason forKey:PARA_MESSAGETEXT];
    }
    
    [self loadPBData:METHOD_HANDLE_JOIN_REQUEST
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}


- (void)inviteMembers:(NSArray *)uids
              groupId:(NSString *)groupId
              titleId:(NSInteger)titleId
             callback:(SimpleResultBlock)callback
{
    NSString *uidsString = [uids componentsJoinedByString:ID_SEPERATOR];
    
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TITLE_ID:@(titleId),
                            PARA_USERID_LIST:uidsString,
                            };
    
    [self loadPBData:METHOD_INVITE_GROUPMEMBERS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)inviteGuests:(NSArray *)uids
             groupId:(NSString *)groupId
            callback:(SimpleResultBlock)callback
{
    NSString *uidsString = [uids componentsJoinedByString:ID_SEPERATOR];
    
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_USERID_LIST:uidsString,
                            };
    
    [self loadPBData:METHOD_INVITE_GROUPGUESTS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}


- (void)getMembersInGroup:(NSString *)groupId
                 callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            };
    
    [self loadPBData:METHOD_GET_GROUP_MEMBERS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, response.groupMemberListList, error);
     }];
}

- (void)expelUser:(NSString *)uid
            group:(NSString *)groupId
           reason:(NSString *)reason   
         callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:uid,
                            PARA_DESC:reason,
                            };
    [self loadPBData:METHOD_EXPEL_GROUPUSER
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)quitGroup:(NSString *)groupId
         callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    [self loadPBData:METHOD_QUIT_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)updateUser:(NSString *)userId
              role:(GroupRole)role
             title:(NSString *)title
           inGroup:(NSString *)groupId
          callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:userId,
                            PARA_ROLE: @(role),
                            PARA_TITLE:(title ? title : @""),
                            };
    [self loadPBData:METHOD_UPDATE_GROUPUSER_ROLE
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}


- (void)followGroup:(NSString *)groupId
           callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    [self loadPBData:METHOD_FOLLOW_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         if (!error) {
             [self.groupManager.followedGroupIds addObject:groupId];
         }
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)unfollowGroup:(NSString *)groupId
             callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    [self loadPBData:METHOD_UNFOLLOW_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         if (!error) {
             [self.groupManager.followedGroupIds removeObject:groupId];
         }
         EXECUTE_BLOCK(callback, error);
     }];    
}

- (void)getGroupFans:(NSString *)groupId
              offset:(NSInteger)offset
               limit:(NSInteger)limit
            callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId, PARA_OFFSET:@(offset), PARA_LIMIT:@(limit)};
    [self loadPBData:METHOD_GET_GROUP_FANS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.userListList, error);
     }];
}

- (void)upgradeGroup:(NSString *)groupId
               level:(NSInteger)level
            callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId, PARA_LEVEL:@(level)};
    [self loadPBData:METHOD_UPGRADE_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, error);
     }];
}



- (void)syncFollowGroupIds
{
    PPDebug(@"<syncFollowGroupIds>");
    [self loadPBData:METHOD_SYNC_FOLLOWED_GROUPIDS
          parameters:@{}
            callback:^(DataQueryResponse *response, NSError *error)
     {
         if (!error) {
             PPDebug(@"<syncFollowGroupIds> Done! follow group size = %d", [response.idListList count]);
             _groupManager.followedGroupIds = [NSMutableArray arrayWithArray:response.idListList];
         }
     }];    
}


//notice
- (void)getGroupNoticeByType:(GroupNoticeType)type
                      offset:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_TYPE:@(type), PARA_OFFSET:@(offset), PARA_LIMIT:@(limit)};
    
    [self loadPBData:METHOD_GET_GROUP_NOTICES
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.noticeListList, error);
     }];
}

- (void)ignoreNotice:(NSString *)noticeId
          noticeType:(NSInteger)type
            callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_TYPE:@(type), PARA_NOTICEID:noticeId};
    
    [self loadPBData:METHOD_IGNORE_NOTICE
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)followTopic:(NSString *)topicId
           callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_POSTID:topicId};
    
    [self loadPBData:METHOD_FOLLOW_TOPIC
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)getFollowedTopicList:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_OFFSET:@(offset), PARA_LIMIT:@(limit)};
    
    [self loadPBData:METHOD_GET_FOLLOWED_TOPIC
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.bbsPostList, error);
     }];
}

- (void)getTopicTimelineList:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_OFFSET:@(offset), PARA_LIMIT:@(limit)};
    
    [self loadPBData:METHOD_GET_TOPIC_TIMELINE
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.bbsPostList, error);
     }];

}

- (void)getRelationWithGroup:(NSString *)groupId
                    callback:(RelationResultBlock)callback
{    
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    [self loadPBData:METHOD_GET_GROUPRELATION
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         PPDebug(@"<loadRelation>: title = %@, permission = %d", response.groupRelation.title, response.groupRelation.permission);
         EXECUTE_BLOCK(callback, response.groupRelation, error);
     }];
}

- (void)getGroupBadgeWithCallback:(BadgeResultBlock)callback
{
    [self loadPBData:METHOD_GET_GROUP_BADGES
          parameters:nil
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.badgesList, error);
     }];
}

- (PBGroup *)buildGroup:(PBGroup *)group
           withRelation:(PBUserRelationWithGroup *)relation
{
    PBGroup_Builder *builder = [PBGroup builderWithPrototype:group];
    [builder setRelation:relation];
    PBGroup *retGroup = [builder build];
    [[GroupManager defaultManager] collectGroup:retGroup];
    return retGroup;
}


- (PBGroup *)buildGroupWithDefaultRelation:(PBGroup *)group
{
    PBUserRelationWithGroup_Builder *builder = [[PBUserRelationWithGroup_Builder alloc] init];
    [builder setRole:GroupRoleNone];
    [builder setPermission:GROUP_DEFAULT_PERMISSION];
    [builder setStatus:0];
    PBUserRelationWithGroup *relation = [builder build];
    [builder release];
    return [self buildGroup:group withRelation:relation];
    
}

- (void)acceptInvitation:(NSString *)noticeId callback:(SimpleResultBlock)callback
{
    [self loadPBData:METHOD_ACCEPT_INVITATION
          parameters:@{PARA_NOTICEID:noticeId}
            callback:^(DataQueryResponse *response, NSError *error) {
        EXECUTE_BLOCK(callback, error);
    }];
}

- (void)rejectInvitation:(NSString *)noticeId callback:(SimpleResultBlock)callback
{
    [self loadPBData:METHOD_REJECT_INVITATION
          parameters:@{PARA_NOTICEID:noticeId}
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];
}


- (void)createGroupTitle:(NSString *)title
                 titleId:(NSInteger)titleId
                 groupId:(NSString *)groupId
                callback:(SimpleResultBlock)callback
{
    NSDictionary *info = @{PARA_TITLE_ID: @(titleId),
                           PARA_TITLE:title,
                           PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_CREATE_GROUP_TITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];

}

- (void)deleteGroupTitleId:(NSInteger)titleId
                   groupId:(NSString *)groupId
                  callback:(SimpleResultBlock)callback
{
    NSDictionary *info = @{PARA_TITLE_ID:@(titleId),
                            PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_DELETE_GROUP_TITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];
}

- (void)changeUser:(NSString *)userId
           inGroup:(NSString *)groupId
     sourceTitleId:(NSInteger)sourceTitleId
             title:(NSInteger)titleId
          callback:(SimpleResultBlock)callback
{
    NSDictionary *info = @{PARA_TITLE_ID : @(titleId),
                           PARA_SOURCE_TITLEID : @(sourceTitleId),
                           PARA_GROUPID : groupId,
                           PARA_TARGETUSERID : userId
                           };
    
    [self loadPBData:METHOD_CHANGE_USER_TITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];
}

- (void)getAllUsersByTitle:(NSString *)groupId
                  callback:(ListResultBlock)callback
{
    NSDictionary *info = @{PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_GET_USERS_BYTITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, response.groupMemberListList, error);
    }];
}

- (void)editGroup:(NSString *)groupId
             info:(NSDictionary *)info
         callback:(SimpleResultBlock)callback
{
    [self loadPBData:METHOD_EDIT_GROUP
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];
}

@end
