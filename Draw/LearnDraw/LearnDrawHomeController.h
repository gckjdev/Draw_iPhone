//
//  LearnDrawHomeController.h
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "HomeBottomMenuPanel.h"
#import "CommonTabController.h"

@interface LearnDrawHomeController : CommonTabController<HomeBottomMenuPanelDelegate>

- (void)reloadTableView;

@end
