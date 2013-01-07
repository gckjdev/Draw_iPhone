//
//  DraftsView.h
//  Draw
//
//  Created by 王 小涛 on 13-1-5.
//
//

#import <UIKit/UIKit.h>
#import "MyPaint.h"

@protocol DraftsViewDelegate <NSObject>

@optional
- (void)didSelectDraft:(MyPaint *)draft;

@end


@interface DraftsView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableView;

+ (id)createView;


@end
