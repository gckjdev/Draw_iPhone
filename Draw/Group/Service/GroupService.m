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

#ifdef DEBUG
    #define GROUP_HOST     @"http://localhost:8100/api?"
#else
    #define GROUP_HOST     GlobalGetTrafficServerURL()
#endif


typedef void (^ PBResponseResultBlock) (DataQueryResponse *response, NSError* error);

static GroupService *_staticGroupService = nil;

@implementation GroupService

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
- (void)getNewGroups:(NSInteger)offset
               limit:(NSInteger)limit
            callback:(ListResultBlock)callback
{
    NSDictionary *paras = @{PARA_OFFSET:@(offset), PARA_LIMIT:@(limit)};
    
    [self loadPBData:METHOD_GET_NEW_GROUPS
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error) {                
        EXECUTE_BLOCK(callback, response.groupListList, error);
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


#define HANDLE_TYPE_ACCEPT @(1)
#define HANDLE_TYPE_REJECT @(2)

- (void)acceptUser:(NSString *)uid
             group:(NSString *)groupId
          callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:uid,
                            PARA_TYPE:HANDLE_TYPE_ACCEPT
                            };
    
    [self loadPBData:METHOD_HANDLE_JOIN_REQUEST
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)rejectUser:(NSString *)uid
             group:(NSString *)groupId
            reason:(NSString *)reason
          callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:uid,
                            PARA_DESC:reason,
                            PARA_TYPE:HANDLE_TYPE_REJECT
                            };
    
    [self loadPBData:METHOD_HANDLE_JOIN_REQUEST
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)inviteUsers:(NSArray *)uids
              group:(NSString *)groupId
               type:(InviteUserType)type
           callback:(SimpleResultBlock)callback
{
    NSString *uidsString = [uids componentsJoinedByString:ID_SEPERATOR];
    
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_USERID_LIST:uidsString,
                            PARA_TYPE:@(type),
                            };
    
    [self loadPBData:METHOD_INVITE_GROUPUSER
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

@end
