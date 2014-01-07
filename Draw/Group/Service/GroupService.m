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
#import "DrawError.h"
#import "PPConfigManager.h"
#import "UIImageExt.h"
#import "GroupPermission.h"
#import "AccountService.h"


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
                
                NSError *error = DRAW_ERROR(output.resultCode);
                if (error) {
                    PPDebug(@"<GroupService> load data error = %@, method = %@", error, method);
                    [DrawError postError:error];
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
        if (!error) {
            [self syncGroupRoles];
        }
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


- (void)getSimpleGroup:(NSString *)groupId
              callback:(GroupResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_GET_SIMPLE_GROUP
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
         if (!error) {
             [self syncGroupRoles];
         }
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
         if (!error) {
             [[GroupService defaultService] syncGroupRoles];
         }
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

- (void)expelUser:(PBGameUser *)user
            group:(NSString *)groupId
          titleId:(NSInteger)titleId
           reason:(NSString *)reason
         callback:(SimpleResultBlock)callback
{
    if (!reason) {
        reason = @"";
    }
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:user.userId,
                            PARA_DESC:reason,
                            PARA_TITLE_ID:@(titleId)
                            };
    [self loadPBData:METHOD_EXPEL_GROUPUSER
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         if (!error) {
             [GroupManager didRemoveUser:user fromTitleId:titleId];
         }
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
         if (!error) {
             [[GroupService defaultService] syncGroupRoles];
         }
     }];
}

- (void)setUserAsAdmin:(PBGameUser *)user
               inGroup:(NSString *)groupId
              callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:user.userId,
                            };
    [self loadPBData:METHOD_SET_USER_AS_ADMIN
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)removeUserFromAdmin:(PBGameUser *)user
                    inGroup:(NSString *)groupId
                   callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:user.userId,
                            };
    
    [self loadPBData:METHOD_REMOVE_USER_FROM_ADMIN
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
             PPDebug(@"<syncFollowGroupIds> Done! follow group count = %d", [response.idListList count]);
             [_groupManager syncFollowedGroupIds:response.idListList];
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

- (void)syncFollowTopicIds
{
    [self loadPBData:METHOD_SYNC_FOLLOWED_TOPICIDS parameters:nil callback:^(DataQueryResponse *response, NSError *error) {
        if (!error) {
            [_groupManager syncFollowedTopicIds:response.idListList];
        }
    }];
}

- (void)unfollowTopic:(NSString *)topicId
             callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_POSTID:topicId};
    
    [self loadPBData:METHOD_UNFOLLOW_TOPIC
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error)
     {
         if (!error) {
             [_groupManager didUnfollowTopic:topicId];
         }
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
         if (!error) {
             [_groupManager didFollowTopic:topicId];
         }
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



- (void)getGroupBadgeWithCallback:(BadgeResultBlock)callback
{
    [self loadPBData:METHOD_GET_GROUP_BADGES
          parameters:nil
            callback:^(DataQueryResponse *response, NSError *error)
     {
         EXECUTE_BLOCK(callback, response.badgesList, error);
     }];
}

//充值
- (void)chargeGroup:(NSString *)groupId
             amount:(NSInteger)amount
           callback:(SimpleResultBlock)callback
{
    if (![[AccountService defaultService] hasEnoughBalance:amount currency:PBGameCurrencyCoin]) {
        [DrawError postErrorWithCode:ERROR_BALANCE_NOT_ENOUGH];
        return;
    }
    NSDictionary *params = @{PARA_GROUPID:groupId, PARA_AMOUNT:@(amount)};
    [self loadPBData:METHOD_CHARGE_GROUP
          parameters:params
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
                if (!error) {
                    [[AccountService defaultService] deductCoin:amount source:DeductForChargeGroup];
                }
                EXECUTE_BLOCK(callback, error);                
    }];
}

//转给成员
- (void)transferGroupBalance:(NSString *)groupId
                      amount:(NSInteger)amount
                   targetUid:(NSString *)targetUid
                    callback:(SimpleResultBlock)callback
{
    
    
    NSDictionary *params = @{PARA_GROUPID:groupId,
                             PARA_AMOUNT:@(-amount),
                             PARA_TARGETUSERID: targetUid};
    
    [self loadPBData:METHOD_CHARGE_GROUP
          parameters:params
            callback:^(DataQueryResponse *response, NSError *error) {
                if (!error) {

                }
            EXECUTE_BLOCK(callback, error);                
    }];
}



- (void)acceptInvitation:(NSString *)noticeId callback:(SimpleResultBlock)callback
{
    [self loadPBData:METHOD_ACCEPT_INVITATION
          parameters:@{PARA_NOTICEID:noticeId}
            callback:^(DataQueryResponse *response, NSError *error) {
        EXECUTE_BLOCK(callback, error);
        if (!error) {
            [[GroupService defaultService] syncGroupRoles];
        }
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
                if (!error) {
                    [GroupManager didAddedGroupTitle:groupId title:title titleId:titleId];
                }
                EXECUTE_BLOCK(callback, error);
    }];

}

- (void)updateGroupTitle:(NSString *)groupId
                 titleId:(NSInteger) titleId
                   title:(NSString *)title
                callback:(SimpleResultBlock)callback
{
    NSDictionary *info = @{PARA_TITLE_ID: @(titleId),
                           PARA_TITLE:title,
                           PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_UPDATE_GROUP_TITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                if (!error) {
                    [GroupManager didUpdatedGroupTitle:groupId title:title titleId:titleId];
                }
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
                if (!error) {
                    [GroupManager didDeletedGroupTitle:groupId titleId:titleId];
                }
                EXECUTE_BLOCK(callback, error);
    }];
}

- (void)changeUser:(PBGameUser *)user
           inGroup:(NSString *)groupId
     sourceTitleId:(NSInteger)sourceTitleId
             title:(NSInteger)titleId
          callback:(SimpleResultBlock)callback
{
    NSDictionary *info = @{PARA_TITLE_ID : @(titleId),
                           PARA_SOURCE_TITLEID : @(sourceTitleId),
                           PARA_GROUPID : groupId,
                           PARA_TARGETUSERID : user.userId
                           };
    
    [self loadPBData:METHOD_CHANGE_USER_TITLE
          parameters:info
            callback:^(DataQueryResponse *response, NSError *error) {
                if (!error) {
                    [GroupManager didUpdateUser:user fromTitleId:sourceTitleId toTitleId:titleId];
                }
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
                NSArray *list = response.groupMemberListList;
                if ([list count] > 1) {
                    list = [response.groupMemberListList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        PBGroupUsersByTitle *t1 = obj1;
                        PBGroupUsersByTitle *t2 = obj2;
                        if (t1.title.titleId < t2.title.titleId) {
                            return NSOrderedAscending;
                        }
                        return NSOrderedDescending;
                    }];
                }
                EXECUTE_BLOCK(callback, list, error);
    }];
}

- (void)editGroup:(NSString *)groupId
             info:(NSDictionary *)info
         callback:(SimpleResultBlock)callback
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:info];
    [params setObject:groupId forKey:PARA_GROUPID];
    
    [self loadPBData:METHOD_EDIT_GROUP
          parameters:params
            callback:^(DataQueryResponse *response, NSError *error) {
                EXECUTE_BLOCK(callback, error);
    }];
}

- (void)updateGroup:(NSString *)groupId
             method:(NSString *)method
                key:(NSString *)key
               image:(UIImage *)image
           callback:(URLResultBlock)callback
{
    dispatch_async(workingQueue, ^{
        
        NSDictionary *params = @{PARA_GROUPID:groupId};
        NSDictionary *datas = @{key:[image data]};
        
        GameNetworkOutput *output = [PPGameNetworkRequest trafficApiServerUploadAndResponsePB:method parameters:params imageDataDict:datas postDataDict:nil progressDelegate:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = DRAW_ERROR(output.pbResponse.resultCode);
            NSURL *url = nil;
            if (error) {
                [DrawError postError:error];
            }else{
                url = [NSURL URLWithString:output.pbResponse.url];
                PPDebug(@"<updateGroupImage> url = %@", url);
            }
            EXECUTE_BLOCK(callback, url, error);
        });
    });
}

- (void)updateGroup:(NSString *)groupId
               icon:(UIImage *)icon
           callback:(URLResultBlock)callback
{
    [self updateGroup:groupId
               method:METHOD_UPDATE_GROUP_ICON
                  key:PARA_IMAGE
                image:icon
             callback:callback];
}


- (void)syncGroupRoles
{
    
    [self loadPBData:METHOD_SYNC_GROUP_ROLES
          parameters:nil
            callback:^(DataQueryResponse *response, NSError *error )
     {
         if (!error) {
             PPDebug(@"<syncGroupRoles> roles list count = %d", [response.groupRoleList count]);
             [GroupPermissionManager syncGroupRoles:response.groupRoleList];
         }
     }];
}

- (void)updateGroup:(NSString *)groupId
            BGImage:(UIImage *)image
           callback:(URLResultBlock)callback
{
    [self updateGroup:groupId
               method:METHOD_UPDATE_GROUP_BG
                  key:PARA_IMAGE
                image:image
             callback:callback];
}
@end
