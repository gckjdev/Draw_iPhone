//
//  DraftsView.h
//  Draw
//
//  Created by 王 小涛 on 13-1-5.
//
//

#import <UIKit/UIKit.h>
#import "MyPaint.h"
#import "MyPaintManager.h"
#import "DraftCell.h"

@protocol DraftsViewDelegate <NSObject>

@required
- (void)didSelectDraft:(MyPaint *)draft;

@end


@interface DraftsView : UIView<UITableViewDataSource, UITableViewDelegate, MyPaintManagerDelegate, DraftCellDelegate>

@property (assign, nonatomic) id<DraftsViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *drafts;

+ (id)createWithdelegate:(id<DraftsViewDelegate>)delegate;

@end
