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

@end
