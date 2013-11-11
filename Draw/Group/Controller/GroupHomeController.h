//
//  GroupHomeController.h
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "CommonTabController.h"
#import "DetailFooterView.h"

@interface GroupHomeController : CommonTabController<DetailFooterViewDelegate>
@property (retain, nonatomic) IBOutlet UIView *subTabsHolder;
@property (retain, nonatomic) IBOutlet DetailFooterView *footerView;

@end
