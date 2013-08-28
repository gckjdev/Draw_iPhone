//
//  ContestFeed.h
//  Draw
//
//  Created by  on 12-9-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawFeed.h"

@interface ContestFeed : DrawFeed
{
    NSString *_contestId;
    double _contestScore;
}

@property(nonatomic, retain)NSString *contestId;
@property(nonatomic, assign)double contestScore;
@property(nonatomic, retain)NSArray *rankInfoList;

- (id)initWithPBFeed:(PBFeed *)pbFeed;



@end
