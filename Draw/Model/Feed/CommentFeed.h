//
//  CommentFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"

@interface CommentFeed : Feed
{
    NSString *_comment;
}
@property(nonatomic, retain)NSString *comment;
- (id)initWithPBFeed:(PBFeed *)pbFeed;


@end
