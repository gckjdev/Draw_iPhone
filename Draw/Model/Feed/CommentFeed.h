//
//  CommentFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"


@class CommentInfo;

@interface CommentFeed : Feed
{
    NSString *_comment;
    CommentInfo *_commentInfo;
}
@property(nonatomic, retain)NSString *comment;
@property(nonatomic, retain)CommentInfo *commentInfo;
- (id)initWithPBFeed:(PBFeed *)pbFeed;
- (NSString *)commentInFeedDeatil;
- (NSString *)commentInMyComment;;
- (BOOL)canDelete;
@end


@interface CommentInfo : NSObject {
    NSString *_actionId;
    FeedType _type;
    NSString *_comment;
    NSString *_summary;
    NSString *_actionUid;
    NSString *_actionNick;
}

@property(nonatomic, assign) FeedType type;
@property(nonatomic, retain) NSString *actionId;
@property(nonatomic, retain) NSString *comment;
@property(nonatomic, retain) NSString *summary;
@property(nonatomic, retain) NSString *actionUid;
@property(nonatomic, retain) NSString *actionNick;

- (id)initWithPBCommentInfo:(PBCommentInfo *)pbInfo;
- (NSString *)summaryDesc;
@end