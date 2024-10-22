//
//  GroupHomeController.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "CommonTabController.h"
#import "DetailFooterView.h"
#import "GroupCell.h"
#import "BBSService.h"


@interface GroupHomeController : CommonTabController<DetailFooterViewDelegate, GroupCellDelegate, BBSServiceDelegate>
@property (retain, nonatomic) IBOutlet UIView *subTabsHolder;
@property (retain, nonatomic) IBOutlet UIView *tabsHolderView;
@property (retain, nonatomic) IBOutlet UIView *subTopicTabHolder;

@property (retain, nonatomic) IBOutlet DetailFooterView *footerView;

@end
