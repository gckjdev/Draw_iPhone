//
//  GroupService.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "CommonService.h"
#import "Group.pb.h"
#import "GroupManager.h"

typedef void (^ GroupResultBlock) (PBGroup *group, NSError *error);
typedef void (^ ListResultBlock) (NSArray *list, NSError *error);
typedef void (^ SimpleResultBlock) (NSError *error);



@interface GroupService : CommonService

@property(nonatomic, assign, getter=isTestMode) BOOL testMode;

+ (GroupService *)defaultService;

- (void)createGroup:(NSString *)name
             level:(NSInteger)level
          callback:(GroupResultBlock)callback;

- (void)getGroup:(NSString *)groupId
        callback:(GroupResultBlock)callback;


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

- (void)inviteMembers:(NSArray *)uids
              groupId:(NSString *)groupId
             callback:(SimpleResultBlock)callback;

- (void)inviteGuests:(NSArray *)uids
             groupId:(NSString *)groupId
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



//follow && fan
- (void)followGroup:(NSString *)groupId
           callback:(SimpleResultBlock)callback;

- (void)unfollowGroup:(NSString *)groupId
           callback:(SimpleResultBlock)callback;

- (void)getGroupFans:(NSString *)groupId
              offset:(NSInteger)offset
               limit:(NSInteger)limit
            callback:(ListResultBlock)callback;

- (void)upgradeGroup:(NSString *)groupId
               level:(NSInteger)level
            callback:(SimpleResultBlock)callback;

- (void)getGroupNoticeByType:(GroupNoticeType)type
                      offset:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback;


//new method
- (void)syncFollowGroupIds;
@end
