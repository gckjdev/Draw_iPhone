//
//  BBSService.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "CommonService.h"
#import "BBSManager.h"

@protocol BBSServiceDelegate <NSObject>

@optional
- (void)didGetBBSBoardList:(NSArray *)boardList
                resultCode:(NSInteger)resultCode;

- (void)didCreatePost:(PBBBSPost *)post
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

@end
