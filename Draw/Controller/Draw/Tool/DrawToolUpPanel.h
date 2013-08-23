//
//  DrawToolUpPanel.h
//  Draw
//
//  Created by Kira on 13-6-25.
//
//

#import "DrawToolPanel.h"
#import "DrawView.h"
#import "MyFriend.h"
#import "PPTableViewCell.h"

@class DrawToolUpPanelCell;

@protocol DrawToolUpPanelCellDelegate <NSObject>

- (void)didClickCellControl:(UIControl *)control atCell:(DrawToolUpPanelCell *)cell;
- (void)didClickAccessor:(UIButton *)accessor atCell:(DrawToolUpPanelCell *)cell;

@end

@interface DrawToolUpPanelCell : PPTableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UIControl *control;
@property (retain, nonatomic) IBOutlet UIImageView *icon;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *accessButton;
@property (assign, nonatomic) int type;
@property (retain, nonatomic) IBOutlet UILabel *subject;
- (IBAction)clickAccessButton:(id)sender;
- (IBAction)clickControl:(id)sender;

@end



@interface DrawToolUpPanel : DrawToolPanel<UITableViewDataSource, UITableViewDelegate, DrawToolUpPanelCellDelegate>
{
    NSMutableDictionary *cellDict;
}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic, getter = isBriefStyle) BOOL briefStyle;

//- (IBAction)clickShowCopyPaint:(id)sender;
+ (id)createViewWithDrawView:(DrawView *)drawView
                  briefStyle:(BOOL)briefStyle;

- (void)disappear;
- (void)updateDrawToUser:(MyFriend *)user;
- (void)registerToolCommands;
- (void)updateCopyPaint:(UIImage*)aPhoto;
- (void)updateSubject:(NSString *)subject;
@end
