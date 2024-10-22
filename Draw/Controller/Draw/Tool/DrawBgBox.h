//
//  DrawBgBox.h
//  Draw
//
//  Created by gamy on 13-3-4.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@class PBDrawBg;
@class DrawBgBox;
@class PBDrawBgGroup;
@class DrawBgCell;

@protocol DrawBgBoxDelegate <NSObject>


- (void)drawBgBox:(DrawBgBox *)drawBgBox
didSelectedDrawBg:(PBDrawBg *)drawBg
          groudId:(NSInteger)groupId;

@end

@protocol DrawBgCellDelegate <NSObject>

- (void)drawBgCell:(DrawBgCell *)cell didSelectDrawBg:(PBDrawBg *)bg;

@end

@interface DrawBgBox : UIView<UITableViewDataSource, UITableViewDelegate, DrawBgCellDelegate>

@property(nonatomic, assign) id<DrawBgBoxDelegate> delegate;

+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate;
- (void)dismiss;
- (void)showInView:(UIView *)view;
- (void)reloadView;
@end


//////////////////////
//////////////////////



@interface DrawBgCell : PPTableViewCell

+ (id)createCell:(id)delegate;
+ (CGFloat)getCellHeight;
- (void)updateCellWithDrawBGGroup:(PBDrawBgGroup *)group;

+ (NSString *)getCellIdentifier;

@property(nonatomic, assign)PBDrawBgGroup *group;

@end
