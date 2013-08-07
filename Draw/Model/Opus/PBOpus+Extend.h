//
//  PBOpus+Extend.h
//  Draw
//
//  Created by 王 小涛 on 13-6-29.
//
//

#import "Opus.pb.h"
#import "DrawFeed.h"

@interface PBOpus (Extend)

- (int)feedTimesWithFeedTimesType:(PBFeedTimesType)type;
- (BOOL)isContestOpus;
- (BOOL)isMyOpus;

- (DrawFeed *)toDrawFeed;

@end
