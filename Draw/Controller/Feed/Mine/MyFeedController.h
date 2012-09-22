//
//  MyFeedController.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "CommonTabController.h"
#import "FeedService.h"
#import "RankView.h"

@interface MyFeedController : CommonTabController<FeedServiceDelegate,RankViewDelegate>
{
    
}
@end
