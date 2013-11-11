//
//  GroupService.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "CommonService.h"
#import "GroupPermission.h"
#import "Group.pb.h"

typedef void (^ GroupResultBlock) (PBGroup *group, NSError *error);
typedef void (^ ListResultBlock) (NSArray *list, NSError *error);
typedef void (^ SimpleResultBlock) (NSError *error);

typedef enum{
    InviteUserTypeMember = 1,
    InviteUserTypeGuest = 2,    
}InviteUserType;


typedef enum{
    GetGroupListTypeFollow = 1,
    GetGroupListTypeNew = 2,
    GetGroupListTypeBalance = 3,
    GetGroupListTypeActive = 4,
    GetGroupListTypeFame = 5,
}GetGroupListType;


@interface GroupService : CommonService

@property(nonatomic, assign, getter=isTestMode) BOOL testMode;

+ (GroupService *)defaultService;

- (void)createGroup:(NSString *)name
             level:(NSInteger)level
          callback:(GroupResultBlock)callback;

- (void)getGroup:(NSString *)groupId
        callback:(GroupResultBlock)callback;

- (void)getNewGroups:(NSInteger)offset
               limit:(NSInteger)limit
            callback:(ListResultBlock)callback;

- (void)getGroupsWithType:(GetGroupListType)type
                   offset:(NSInteger)offset
                    limit:(NSInteger)limit
                 callback:(ListResultBlock)callback;



- (void)joinGroup:(NSString *)groupId
          message:(NSString *)message
         callback:(SimpleResultBlock)callback;

- (void)acceptUser:(NSString *)uid
             group:(NSString *)groupId
          callback:(SimpleResultBlock)callback;

- (void)rejectUser:(NSString *)uid
             group:(NSString *)groupId
             reason:(NSString *)reason
          callback:(SimpleResultBlock)callback;

- (void)inviteUsers:(NSArray *)uids
              group:(NSString *)groupId
               type:(InviteUserType)type
           callback:(SimpleResultBlock)callback;

- (void)getMembersInGroup:(NSString *)groupId
                 callback:(ListResultBlock)callback;

- (void)expelUser:(NSString *)uid
            group:(NSString *)groupId
            reason:(NSString *)reason
           callback:(SimpleResultBlock)callback;

- (void)updateUser:(NSString *)userId
              role:(GroupRole)role
             title:(NSString *)title
           inGroup:(NSString *)groupId
          callback:(SimpleResultBlock)callback;

@end
