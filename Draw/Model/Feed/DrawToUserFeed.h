//
//  DrawToUserFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawFeed.h"

@interface DrawToUserFeed : DrawFeed
{
    FeedUser *_targetUser;
}
@property(nonatomic, retain)FeedUser *targetUser;
@end
