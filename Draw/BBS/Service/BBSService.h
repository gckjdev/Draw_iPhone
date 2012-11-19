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

@end




@interface BBSService : CommonService

+ (id)defaultService;
- (void)getBBSBoardList:(id<BBSServiceDelegate>) delegate;

- (void)createPostWithBoardId:(NSString *)boardId
                         text:(NSString *)text
                        image:(UIImage *)image
               drawActionList:(NSArray *)drawActionList
                    drawImage:(UIImage *)drawImage
                        bonus:(NSInteger)bonus
                     delegate:(id<BBSServiceDelegate>)delegate;

- (void)getBBSPostListWithBoardId:(NSString *)boardId
                        targetUid:(NSString *)targetUid
                        rangeType:(RangeType)rangeType
                           offset:(NSInteger)offset
                            limit:(NSInteger)limit
                         delegate:(id<BBSServiceDelegate>)delegate;

- (PBBBSUser *)myself;
@end
