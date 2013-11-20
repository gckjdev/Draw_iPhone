//
//  GroupTopicController.h
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "CommonTabController.h"
#import "BBSPostActionHeaderView.h"

@class PBGroup;
@interface GroupTopicController : CommonTabController<BBSPostActionHeaderViewDelegate>

+ (GroupTopicController *)enterWithGroup:(PBGroup *)group
                          fromController:(PPViewController *)controller;

@end
