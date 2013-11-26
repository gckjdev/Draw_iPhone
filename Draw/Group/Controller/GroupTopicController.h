//
//  GroupTopicController.h
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "CommonTabController.h"
#import "BBSPostActionHeaderView.h"
#import "GroupInfoView.h"
#import "BBSService.h"
#import "DetailFooterView.h"
#import "CreatePostController.h"
#import "BBSController.h"

@class PBGroup;
@interface GroupTopicController : BBSController<BBSPostActionHeaderViewDelegate, GroupInfoViewDelegate, BBSServiceDelegate, DetailFooterViewDelegate, CreatePostControllerDelegate>

+ (GroupTopicController *)enterWithGroup:(PBGroup *)group
                          fromController:(PPViewController *)controller;




@end
