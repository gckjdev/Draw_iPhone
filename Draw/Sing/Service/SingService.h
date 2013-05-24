//
//  SingService.h
//  Draw
//
//  Created by 王 小涛 on 13-5-24.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "Sing.pb.h"

@interface SingService : CommonService

+ (id)defaultService;

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
  progressDelegate:(id)progressDelegate;

@end
