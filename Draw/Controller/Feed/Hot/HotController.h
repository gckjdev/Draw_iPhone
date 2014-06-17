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
//#import "TopPlayerView.h"
#import "UserService.h"
#import "OpusImageBrower.h"
#import "OpusClassInfo.h"

@interface HotController : CommonTabController<FeedServiceDelegate,RankViewDelegate,UserServiceDelegate, UIActionSheetDelegate, OpusImageBrowerDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet UIButton *hotRankSettingButton;
@property (nonatomic, retain) OpusClassInfo* opusClassInfo;

- (IBAction)clickSetHot:(id)sender;

- (id)initWithOpusClass:(OpusClassInfo*)opusClassInfo;

@end
