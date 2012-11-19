//
//  BBSNetwork.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import <Foundation/Foundation.h>
#import "GameNetworkConstants.h"
#import "PPNetworkConstants.h"
@class CommonNetworkOutput;

@interface BBSNetwork : NSObject

+ (CommonNetworkOutput*)getBBSBoardList:(NSString*)baseURL
                                  appId:(NSString*)appId
                                 userId:(NSString*)userId
                             deviceType:(int)deviceType;

+ (CommonNetworkOutput*)createPost:(NSString*)baseURL
                             appId:(NSString*)appId
                        deviceType:(int)deviceType
                            userId:(NSString*)userId
                          nickName:(NSString*)nickName
                            gender:(NSString*)gender
                            avatar:(NSString*)avatar
                           boradId:(NSString*)boardId
                       contentType:(NSInteger)contentType
                              text:(NSString *)text
                             image:(NSData *)image
                          drawData:(NSData *)drawData
                         drawImage:(NSData *)drawImage
                             bonus:(NSInteger)bonus;

+ (CommonNetworkOutput*)getPostList:(NSString*)baseURL
                              appId:(NSString*)appId
                         deviceType:(int)deviceType
                             userId:(NSString*)userId
                          targetUid:(NSString*)targetUid
                            boardId:(NSString*)boardId
                          rangeType:(NSInteger)rangeType
                             offset:(NSInteger)offset
                              limit:(NSInteger)limit;



//- (void)createPostWithBoardId:(NSString *)boardId
//                         text:(NSString *)text
//                        image:(UIImage *)image
//               drawActionList:(NSArray *)drawActionList
//                    drawImage:(UIImage *)drawImage
//                     delegate:(id<BBSServiceDelegate>)delegate
//{
//    dispatch_async(workingQueue, ^{
//        NSInteger deviceType = [DeviceDetection deviceType];
//        NSString *appId = [ConfigManager appId];
//        
//        NSString *userId = [[UserManager defaultManager] userId];
//        NSString *nickName = [[UserManager defaultManager] nickName];
//        NSString *gender = [[UserManager defaultManager] gender];
//        NSString *avatar = [[UserManager defaultManager] avatarURL];
//        
//        BBSPostContentType type = ContentTypeText;
//        if (image) {
//            type = ContentTypeImage;
//        }else if (drawImage) {
//            type = ContentTypeDraw;
//        }
//        
//        
//    });
//}

@end
