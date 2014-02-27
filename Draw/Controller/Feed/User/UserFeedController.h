//
//  UserFeedController.h
//  Draw
//
//  Created by  on 12-6-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
//#import "FeedCell.h"
#import "FeedService.h"
#import "CommonTabController.h"
#import "RankView.h"
#import "OpusImageBrower.h"
#import "CommonDialog.h"
#import "FriendController.h"
#import "ShareAction.h"

typedef void (^UserFeedControllerSelectResultBlock)(int resultCode, NSString* opusId, UIImage* opusImage, int opusCategory);

@interface UserFeedController : CommonTabController<FeedServiceDelegate, RankViewDelegate,
UIActionSheetDelegate, OpusImageBrowerDelegate, CommonDialogDelegate, FriendControllerDelegate, DrawDataServiceDelegate>
{
    NSString *_userId;
    NSString *_nickName;
}

@property(nonatomic, retain)NSString *userId;
@property(nonatomic, retain)NSString *nickName;
@property(nonatomic, retain)ShareAction *shareAction;

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName;

- (id)initWithUserId:(NSString *)userId
            nickName:(NSString *)nickName
     defaultTabIndex:(int)defaultTabIndex;


+ (UserFeedController*)selectOpus:(PPViewController*)fromController callback:(UserFeedControllerSelectResultBlock)callback;

@end
