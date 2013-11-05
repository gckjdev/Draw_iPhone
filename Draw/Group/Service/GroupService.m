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

#define GROUP_HOST     GlobalGetTrafficServerURL()


typedef void (^ PBResponseResultBlock) (DataQueryResponse *response, NSError* error);

@implementation GroupService

- (void)loadPBData:(NSString *)method
      parameters:(NSDictionary *)parameters
        callback:(PBResponseResultBlock)callback
{
    dispatch_async(workingQueue, ^{
        GameNetworkOutput* output = [PPGameNetworkRequest
                                     sendGetRequestWithBaseURL:GROUP_HOST
                                     method:method
                                     parameters:parameters
                                     returnPB:YES
                                     returnJSONArray:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = DRAW_ERROR(output.pbResponse.resultCode); 
            EXECUTE_BLOCK(callback, output.pbResponse, error);
        });
    });
   
}

- (void)creatGroup:(NSString *)name
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
            EXECUTE_BLOCK(callback, response.group, error);
    }];
}

- (void)getGroup:(NSString *)groupId
        callback:(GroupResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_GET_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, response.group, error);
     }];
}

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


- (void)joinGroup:(NSString *)groupId
         callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId};
    
    [self loadPBData:METHOD_JOIN_GROUP
          parameters:paras
            callback:^(DataQueryResponse *response, NSError *error )
     {
         EXECUTE_BLOCK(callback, error);
     }];
}

- (void)acceptUser:(NSString *)uid
             group:(NSString *)groupId
          callback:(SimpleResultBlock)callback
{
    NSDictionary *paras = @{PARA_GROUPID:groupId,
                            PARA_TARGETUSERID:uid
                            };
    
    [self loadPBData:METHOD_ACCEPT_JOIN_REQUEST
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
                            };
    [self loadPBData:METHOD_REJECT_JOIN_REQUEST
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
