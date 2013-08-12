//
//  HotController.h
//  Draw
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonTabController.h"
#import "FeedService.h"
#import "RankView.h"
#import "TopPlayerView.h"
#import "UserService.h"
#import "OpusImageBrower.h"

@interface HotController : CommonTabController<FeedServiceDelegate,RankViewDelegate,TopPlayerViewDelegate,UserServiceDelegate, UIActionSheetDelegate, OpusImageBrowerDelegate>
{
    
}


@end
