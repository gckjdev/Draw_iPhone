//
//  PBOpus+Extend.m
//  Draw
//
//  Created by 王 小涛 on 13-6-29.
//
//

#import "PBOpus+Extend.h"
#import "UserManager.h"

@implementation PBOpus (Extend)

- (int)feedTimesWithFeedTimesType:(PBFeedTimesType)feedTimesType{

    for (PBFeedTimes *feedTimes in self.feedTimesList) {
        if (feedTimes.type == feedTimesType) {
            return feedTimes.value;
        }
    }
    
    return 0;
}

- (BOOL)isContestOpus{
    
    if ([self.contestId length] <= 0) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)isMyOpus{
    
    if ([[[UserManager defaultManager] userId] isEqualToString:self.author.userId]) {
        return YES;
    }else{
        return NO;
    }
}

- (DrawFeed *)toDrawFeed{
    
    return [[[DrawFeed alloc] initWithFeedId:self.opusId
                                      userId:self.author.userId
                                    nickName:self.author.nickName
                                      avatar:self.author.avatar
                                      gender:self.author.gender
                                   signature:self.author.signature
                                drawImageUrl:self.image
                                      pbDraw:nil
                                    wordText:self.name
                                   contestId:self.contestId
                                  timesArray:nil] autorelease];
    
}

@end
