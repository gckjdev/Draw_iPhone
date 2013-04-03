//
//  BBSService.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "CommonService.h"
#import "BBSManager.h"

typedef enum{
    RangeTypeNew = 0,
    RangeTypeHot = 1,
}RangeType;

@protocol BBSServiceDelegate <NSObject>

@optional
- (void)didGetBBSBoardList:(NSArray *)boardList
                resultCode:(NSInteger)resultCode;

- (void)didCreatePost:(PBBBSPost *)post
           resultCode:(NSInteger)resultCode;

- (void)didGetBBSBoard:(NSString *)boardId
              postList:(NSArray *)postList
             rangeType:(RangeType)rangeType
            resultCode:(NSInteger)resultCode;

- (void)didGetUser:(NSString *)userId
              postList:(NSArray *)postList
            resultCode:(NSInteger)resultCode;

- (void)didCreateAction:(PBBBSAction *)action
                 atPost:(NSString *)postId
            replyAction:(PBBBSAction *)replyAction
             resultCode:(NSInteger)resultCode;

- (void)didGetActionList:(NSArray *)actionList
               belowPost:(NSString *)postId
              actionType:(BBSActionType)actionType
              resultCode:(NSInteger)resultCode;

- (void)didGetActionList:(NSArray *)actionList
               targetUid:(NSString *)targetUid
              resultCode:(NSInteger)resultCode;

//delete methods
//- (void)didDeleteBBSPost:(NSString *)postId
//              resultCode:(NSInteger)resultCode;

- (void)didDeleteBBSPost:(PBBBSPost *)post
              resultCode:(NSInteger)resultCode;

- (void)didDeleteBBSAction:(NSString *)actionId
                resultCode:(NSInteger)resultCode;

//get draw action list methods
- (void)didGetBBSDrawActionList:(NSMutableArray *)drawActionList
                drawDataVersion:(NSInteger)version
                     canvasSize:(CGSize)canvasSize
                         postId:(NSString *)postId
                       actionId:(NSString *)actionId
                     fromRemote:(BOOL)fromRemote
                     resultCode:(NSInteger)resultCode;

//get post detail method
- (void)didGetBBSPost:(PBBBSPost *)post
               postId:(NSString *)postId
           resultCode:(NSInteger)resultCode;

- (void)didPayBBSRewardWithPost:(PBBBSPost *)post
                         action:(PBBBSAction *)action
                     resultCode:(NSInteger)resultCode;

- (void)didEditPostPost:(PBBBSPost *)post
             resultCode:(NSInteger)resultCode;


- (void)didChangeUser:(NSString *)userId
                 role:(BBSUserRole)role
              boardId:(NSString *)boardId
             resultCode:(NSInteger)resultCode;

@end




@interface BBSService : CommonService

+ (id)defaultService;

#pragma mark - bbs board methods
- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate;



#pragma mark - bbs post methods
- (void)createPostWithBoardId:(NSString *)boardId
                         text:(NSString *)text
                        image:(UIImage *)image
               drawActionList:(NSArray *)drawActionList
                    drawImage:(UIImage *)drawImage
                        bonus:(NSInteger)bonus
                     delegate:(id<BBSServiceDelegate>)delegate
                   canvasSize:(CGSize)size;

- (void)getBBSPostListWithBoardId:(NSString *)boardId
                        targetUid:(NSString *)targetUid
                        rangeType:(RangeType)rangeType
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<BBSServiceDelegate>)delegate;



//- (void)pay

#pragma mark - bbs action methods
- (void)createActionWithPostId:(NSString *)postId
                       PostUid:(NSString *)postUid
                      postText:(NSString *)postText
                  sourceAction:(PBBBSAction *)sourceAction
                    actionType:(BBSActionType)actionType
                          text:(NSString *)text
                         image:(UIImage *)image
                drawActionList:(NSArray *)drawActionList
                     drawImage:(UIImage *)drawImage
                      delegate:(id<BBSServiceDelegate>)delegate
                    canvasSize:(CGSize)size;

//- (void)createActionWithPost:(PBBBSPost *)post
//                sourceAction:(PBBBSAction *)action
//                  actionType:(BBSActionType)actionType
//                        text:(NSString *)text
//                       image:(UIImage *)image
//              drawActionList:(NSArray *)drawActionList
//                   drawImage:(UIImage *)drawImage
//                    delegate:(id<BBSServiceDelegate>)delegate;

- (void)getBBSActionListWithPostId:(NSString *)postId
                        actionType:(BBSActionType)actionType
                            offset:(NSInteger)offset
                             limit:(NSInteger)limit
                          delegate:(id<BBSServiceDelegate>)delegate;

- (void)getBBSActionListWithTargetUid:(NSString *)targetUid
                            offset:(NSInteger)offset
                             limit:(NSInteger)limit
                          delegate:(id<BBSServiceDelegate>)delegate;

- (void)payRewardWithPost:(PBBBSPost *)post
                   action:(PBBBSAction *)action
                 delegate:(id<BBSServiceDelegate>)delegate;

#pragma mark - common methods
- (void)getBBSDrawDataWithPostId:(NSString *)postId
                        actionId:(NSString *)actionId
                        delegate:(id<BBSServiceDelegate>)delegate;

- (void)getBBSPostWithPostId:(NSString *)postId
                    delegate:(id<BBSServiceDelegate>)delegate;

//- (void)deletePostWithPostId:(NSString *)postId
//                    delegate:(id<BBSServiceDelegate>)delegate;

- (void)deletePost:(PBBBSPost *)post
                    delegate:(id<BBSServiceDelegate>)delegate;

- (void)deleteActionWithActionId:(NSString *)actionId
                        delegate:(id<BBSServiceDelegate>)delegate;

#pragma mark - update post methods

- (void)editPost:(PBBBSPost *)post
         boardId:(NSString *)boardId
          status:(NSInteger)status
            info:(NSDictionary *)info //for the futrue
        delegate:(id<BBSServiceDelegate>)delegate;



#pragma mark - bbs privilege methods
- (void)changeBBSUser:(NSString *)targetUid
              role:(BBSUserRole)role
           boardId:(NSString *)boardId
        expireDate:(NSDate *)expireDate
              info:(NSDictionary *)info //for the futrue
          delegate:(id<BBSServiceDelegate>)delegate;

- (void)getBBSPrivilegeList;

#pragma mark - bbs user methods


- (PBBBSUser *)myself;
@end
