//
//  WallService.m
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import "WallService.h"
#import "SynthesizeSingleton.h"
#import "UserManager.h"

@implementation WallService

SYNTHESIZE_SINGLETON_FOR_CLASS(WallService);

- (void)createWall:(PBWall *)wall
{
    NSString* userId = [[UserManager defaultManager] userId];
//    PBDraw* draw = [self buildPBDraw:userId
//                                nick:nick
//                              avatar:avatar
//                      drawActionList:drawActionList
//                            drawWord:drawWord
//                            language:language];
//    
//    NSData *imageData = nil;
//    if (image) {
//        imageData = [image data];
//    }
//    
//    dispatch_async(workingQueue, ^{
//        CommonNetworkOutput* output = [GameNetworkRequest createOpus:TRAFFIC_SERVER_URL
//                                                               appId:appId
//                                                              userId:userId
//                                                                nick:nick
//                                                              avatar:avatar
//                                                              gender:gender
//                                                              wordId:drawWord.wordId
//                                                                word:drawWord.text
//                                                            wordType:drawWord.wordType
//                                                               level:drawWord.level
//                                                               score:drawWord.score
//                                                                lang:language
//                                                                data:[draw data]
//                                                           imageData:imageData
//                                                           targetUid:targetUid
//                                                           contestId:contestId
//                                                                desc:desc];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([viewController respondsToSelector:@selector(didCreateDraw:)]){
//                [viewController didCreateDraw: output.resultCode];
//            }
//        });
//        NSString *actionId = [output.jsonDataDict objectForKey:PARA_FEED_ID];
//        if ([actionId length] != 0) {
//            //store the draw action.
//            
//        }
//    });
}


@end
