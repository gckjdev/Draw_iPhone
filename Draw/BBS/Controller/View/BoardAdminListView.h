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

@property (nonatomic ,assign) PPViewController *controller;
@property (nonatomic ,retain) NSString *boardId;
@property (retain, nonatomic) IBOutlet UILabel *adminTitle;
@property (retain, nonatomic) IBOutlet UIView *splitLine;

+ (id)adminListViewWithBBSUserList:(NSArray *)userList
                        controller:(PPViewController *)controller
                           boardId:(NSString*)boardId;

@end
