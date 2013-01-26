//
//  BoardAdminListView.h
//  Draw
//
//  Created by gamy on 13-1-26.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@interface BoardAdminListView : UIView
@property (nonatomic ,assign)PPViewController *controller;


+ (id)adminListViewWithBBSUserList:(NSArray *)userList
                        controller:(PPViewController *)controller;

@end
