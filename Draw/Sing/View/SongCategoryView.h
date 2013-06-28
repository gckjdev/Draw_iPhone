//
//  SongCategoryView.h
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import <UIKit/UIKit.h>

@protocol SongCategoryViewDelegate <NSObject>

@optional
- (void)didClickBgButton;
- (void)didSelectTag:(NSString *)tag;

@end

@interface SongCategoryView : UIView
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) id delegate;

+ (id)createCategoryView;
- (void)showInView:(UIView *)view;
//- (void)dismiss;

@end
