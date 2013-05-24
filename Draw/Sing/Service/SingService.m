//
//  SingService.m
//  Draw
//
//  Created by 王 小涛 on 13-5-24.
//
//

#import "SingService.h"
#import "AutoCreateViewByXib.h"
#import "GameNetworkRequest.h"
#import "UserManager.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "GameMessage.pb.h"

@implementation SingService

AUTO_CREATE_VIEW_BY_XIB(SingService);

- (void)submitFeed:(int)type
              word:(NSString *)word
              desc:(NSString *)desc
          toUserId:(NSString *)toUserId
        toUserNick:(NSString *)toUserNick
         contestId:(NSString *)contestId
              song:(PBSong *)song
          singData:(NSData *)singData
         imageData:(NSData *)imageData
         voiceType:(int)voiceType
          duration:(float)duration
             pitch:(float)pitch
  progressDelegate:(id)progressDelegate{
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest submitFeed:TRAFFIC_SERVER_URL
                                                                type:type
                                                                word:word
                                                                desc:desc
                                                              userId:[[UserManager defaultManager] userId]
                                                           targetUid:toUserId
                                                           contestId:contestId
                                                              songId:song.songId
                                                            singData:singData
                                                           imageData:imageData
                                                           voiceType:voiceType
                                                            duration:duration
                                                               pitch:pitch
                                                    progressDelegate:progressDelegate];
        
        NSInteger resultCode = output.resultCode;
        
        if (resultCode == ERROR_SUCCESS) {
            @try {
                
            }
            @catch (NSException *exception) {
                PPDebug(@"<%s>exception = %@", __FUNCTION__, [exception debugDescription]);
            }
            @finally {
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}



@end
