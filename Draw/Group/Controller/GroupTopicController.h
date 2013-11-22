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

@class PBGroup;
@interface GroupTopicController : CommonTabController<BBSPostActionHeaderViewDelegate, GroupInfoViewDelegate, BBSServiceDelegate, DetailFooterViewDelegate>

+ (GroupTopicController *)enterWithGroup:(PBGroup *)group
                          fromController:(PPViewController *)controller;




@end
