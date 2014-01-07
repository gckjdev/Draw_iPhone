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
typedef void (^ BadgeResultBlock) (NSArray *badges, NSError *error);
typedef void (^ ListResultBlock) (NSArray *list, NSError *error);
typedef void (^ SimpleResultBlock) (NSError *error);
typedef void (^ URLResultBlock) (NSURL *url, NSError *error);


@interface GroupService : CommonService

@property(nonatomic, assign, getter=isTestMode) BOOL testMode;

+ (GroupService *)defaultService;

- (void)createGroup:(NSString *)name
             level:(NSInteger)level
          callback:(GroupResultBlock)callback;

- (void)getGroup:(NSString *)groupId
        callback:(GroupResultBlock)callback;

//without admin list, guest list, creator
- (void)getSimpleGroup:(NSString *)groupId
              callback:(GroupResultBlock)callback;


- (void)getGroupsWithType:(GetGroupListType)type
                   offset:(NSInteger)offset
                    limit:(NSInteger)limit
                 callback:(ListResultBlock)callback;

- (void)searchGroupsByKeyword:(NSString *)keyword
                       offset:(NSInteger)offset
                        limit:(NSInteger)limit
                     callback:(ListResultBlock)callback;

- (void)joinGroup:(NSString *)groupId
          message:(NSString *)message
         callback:(SimpleResultBlock)callback;


- (void)handleUserRequestNotice:(PBGroupNotice *)notice
                         accept:(BOOL)accept
                         reason:(NSString *)reason
                       callback:(SimpleResultBlock)callback;

- (void)acceptInvitation:(NSString *)noticeId
                callback:(SimpleResultBlock)callback;

- (void)rejectInvitation:(NSString *)noticeId
                callback:(SimpleResultBlock)callback;

- (void)inviteMembers:(NSArray *)uids
              groupId:(NSString *)groupId
              titleId:(NSInteger)titleId
             callback:(SimpleResultBlock)callback;

- (void)inviteGuests:(NSArray *)uids
             groupId:(NSString *)groupId
             callback:(SimpleResultBlock)callback;


- (void)getMembersInGroup:(NSString *)groupId
                 callback:(ListResultBlock)callback;

- (void)expelUser:(PBGameUser *)user
            group:(NSString *)groupId
          titleId:(NSInteger)titleId
            reason:(NSString *)reason
           callback:(SimpleResultBlock)callback;

- (void)quitGroup:(NSString *)groupId
         callback:(SimpleResultBlock)callback;



- (void)setUserAsAdmin:(PBGameUser *)user
               inGroup:(NSString *)groupId
              callback:(SimpleResultBlock)callback;

- (void)removeUserFromAdmin:(PBGameUser *)user
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



//new method
- (void)syncFollowGroupIds;


//notice service
- (void)getGroupNoticeByType:(GroupNoticeType)type
                      offset:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback;

- (void)ignoreNotice:(NSString *)noticeId
          noticeType:(NSInteger)type
            callback:(SimpleResultBlock)callback;


- (void)syncFollowTopicIds;

- (void)unfollowTopic:(NSString *)topicId
           callback:(SimpleResultBlock)callback;

- (void)followTopic:(NSString *)topicId
           callback:(SimpleResultBlock)callback;

- (void)getFollowedTopicList:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback;

- (void)getTopicTimelineList:(NSInteger)offset
                       limit:(NSInteger)limit
                    callback:(ListResultBlock)callback;


- (void)getGroupBadgeWithCallback:(BadgeResultBlock)callback;


- (void)chargeGroup:(NSString *)groupId
             amount:(NSInteger)amount
           callback:(SimpleResultBlock)callback;

- (void)transferGroupBalance:(NSString *)groupId
                      amount:(NSInteger)amount
                   targetUid:(NSString *)targetUid
                    callback:(SimpleResultBlock)callback;


///


//group title
- (void)createGroupTitle:(NSString *)title
                 titleId:(NSInteger)titleId
                 groupId:(NSString *)groupId
                callback:(SimpleResultBlock)callback;

- (void)deleteGroupTitleId:(NSInteger)titleId
                   groupId:(NSString *)groupId
                  callback:(SimpleResultBlock)callback;

- (void)updateGroupTitle:(NSString *)groupId
                 titleId:(NSInteger) titleId
                   title:(NSString *)title
                callback:(SimpleResultBlock)callback;

- (void)changeUser:(PBGameUser *)user
           inGroup:(NSString *)groupId
     sourceTitleId:(NSInteger)sourceTitleId
             title:(NSInteger)titleId
          callback:(SimpleResultBlock)callback;

//- (void)remove

- (void)getAllUsersByTitle:(NSString *)groupId
                  callback:(ListResultBlock)callback;


//edit
- (void)editGroup:(NSString *)groupId
             info:(NSDictionary *)info
         callback:(SimpleResultBlock)callback;


- (void)updateGroup:(NSString *)groupId
            BGImage:(UIImage *)image
           callback:(URLResultBlock)callback;

- (void)updateGroup:(NSString *)groupId
               icon:(UIImage *)icon
           callback:(URLResultBlock)callback;


- (void)syncGroupRoles;

@end
