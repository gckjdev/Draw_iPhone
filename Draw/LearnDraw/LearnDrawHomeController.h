//
//  LearnDrawHomeController.h
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "HomeBottomMenuPanel.h"
#import "CommonTabController.h"
#import "PhotoDrawSheet.h"

@interface LearnDrawHomeController : CommonTabController<HomeBottomMenuPanelDelegate, PhotoDrawSheetDelegate>

- (void)reloadTableView;

@end
