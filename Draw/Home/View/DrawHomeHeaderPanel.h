//
//  DrawHomeHeaderPanel.h
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "HomeHeaderPanel.h"

typedef enum{
    DrawHeaderPanelStatusClose = 1,
    DrawHeaderPanelStatusOpen = 2,
    DrawHeaderPanelStatusAnimating = 3,
}DrawHeaderPanelStatus;

@interface DrawHomeHeaderPanel : HomeHeaderPanel<UITableViewDataSource, UITableViewDelegate>
{

}
- (void)openAnimated:(BOOL)animated;
- (void)closeAnimated:(BOOL)animated;

@property (assign, nonatomic) DrawHeaderPanelStatus status;
@property (retain, nonatomic) IBOutlet UIView *holderView;
@property (retain, nonatomic) NSArray *opusList;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *displayHolder;
@property (retain, nonatomic) IBOutlet UIButton *rope;
- (IBAction)clickRope:(id)sender;
@end
