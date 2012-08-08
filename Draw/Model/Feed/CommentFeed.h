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
- (id)initWithCommentFeedId:(NSString *)feedId 
          opusStatus:(OpusStatus)status 
          createData:(NSDate *)createDate 
            feedUser:(FeedUser*)feedUser
           comment:(NSString *)comment;


//- (id)initWithGuessFeedId:(NSString *)feedId 
//          opusStatus:(OpusStatus)status 
//          createData:(NSDate *)createDate 
//            feedUser:(FeedUser*)feedUser
//             correct:(BOOL)correct
//           guessList:(NSArray *)guessList;


@end
