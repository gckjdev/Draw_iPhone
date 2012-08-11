//
//  GuessFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"

@class DrawFeed;
@interface GuessFeed : Feed
{
    DrawFeed *_drawFeed;
    NSArray *_guessWords;  
    BOOL _correct;
    NSInteger _score;
}
@property(nonatomic,retain)DrawFeed *drawFeed;
@property(nonatomic,retain)NSArray *guessWords;
@property(nonatomic,assign)NSInteger score;
@property(nonatomic,assign)BOOL correct;


- (id)initWithPBFeed:(PBFeed *)pbFeed;
- (NSInteger)guessTimes;
- (NSInteger)correctTimes;

- (NSInteger)matchTimes;
- (NSInteger)saveTimes;
- (NSInteger)flowerTimes;
- (NSInteger)tomatoTimes;

@end
