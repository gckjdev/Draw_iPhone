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

typedef void (^HeaderAnimationHandler)(BOOL open);
#define HEADER_ANIMATION_INTEVAL 1.2

@interface DrawHomeHeaderPanel : HomeHeaderPanel<UITableViewDataSource, UITableViewDelegate>
{

}
- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion;
- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion;

@property (assign, nonatomic) DrawHeaderPanelStatus status;
@property (retain, nonatomic) IBOutlet UIView *holderView;
@property (retain, nonatomic) NSArray *opusList;
@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *displayHolder;
@property (retain, nonatomic) IBOutlet UIButton *rope;

@property (copy, nonatomic) HeaderAnimationHandler clickRopeHandler;
//@property (copy, nonatomic) HeaderAnimationHandler startHandler;
//@property (copy, nonatomic) HeaderAnimationHandler finishHandler;

- (IBAction)clickRope:(id)sender;
@end
