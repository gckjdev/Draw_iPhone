//
//  ShapeBox.h
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import <UIKit/UIKit.h>
#import "ShapeInfo.h"
#import "PPTableViewCell.h"


@class ShapeBox;
@class PBImageShapeGroup;
@class ShapeGroupCell;

@protocol ShapeBoxDelegate <NSObject>


- (void)shapeBox:(ShapeBox *)shapeBox
didSelectedShape:(ShapeType)shape
        isStroke:(BOOL)isStroke
         groudId:(ItemType)groupId;

- (void)shapeBox:(ShapeBox *)shapeBox
didChangeDrawStyle:(BOOL)stroke;

@end

@protocol ShapeGroupCellDelegate <NSObject>

- (void)shapeGroupCell:(ShapeGroupCell *)cell didSelectedShape:(ShapeType)shape;

@end

@interface ShapeBox : UIView<UITableViewDataSource, UITableViewDelegate, ShapeGroupCellDelegate>

@property(nonatomic, assign) id<ShapeBoxDelegate> delegate;

+ (id)shapeBoxWithDelegate:(id<ShapeBoxDelegate>)delegate;
- (void)dismiss;
- (void)showInView:(UIView *)view;
- (void)reloadView;

// Draw Style
- (void)setStroke:(BOOL)stroke;
- (BOOL)isStroke;
@end


//////////////////////
//////////////////////



@interface ShapeGroupCell : PPTableViewCell

+ (id)createCell:(id)delegate;
+ (CGFloat)getCellHeight;
- (void)updateCellWithImageShapeGroup:(PBImageShapeGroup *)group;

+ (NSString *)getCellIdentifier;

@property(nonatomic, assign)PBImageShapeGroup *group;

@end
