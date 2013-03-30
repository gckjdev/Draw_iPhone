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

@interface DrawBgBox : UIView<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign) id<DrawBgBoxDelegate> delegate;
- (void)updateViewsWithSelectedBgId:(NSString *)bgId;

+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate;

@end


//////////////////////
//////////////////////

@interface DrawBgCell : PPTableViewCell

+ (id)createCell:(id)delegate;
+ (CGFloat)getCellHeight;
- (void)updateCellWithDrawBGGroup:(PBDrawBgGroup *)group;

+ (NSString *)getCellIdentifier;

@end
