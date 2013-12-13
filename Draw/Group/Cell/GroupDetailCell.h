//
//  GroupDetailCell.h
//  Draw
//
//  Created by Gamy on 13-11-18.
//
//

#import "PPTableViewCell.h"

#import "Group.pb.h"
#import "StableView.h"

//@class PBGroup;

@protocol GroupDetailCellDelegate <NSObject>

//- (void)didClickAvatar

@end

typedef enum {
    CellRowPositionFirst = 0,
    CellRowPositionMid = 1,
    CellRowPositionLast = 2,
} CellRowPosition;





typedef enum {
    DetailCellStyleSimpleText = 1,
    DetailCellStyleSingleAvatar = 2,
    DetailCellStyleMultipleAvatars = 3,
}DetailCellStyle;

@interface GroupDetailCell : PPTableViewCell<AvatarViewDelegate>

@property(nonatomic, copy) NSString *text;

+ (id)createCell:(id<GroupDetailCellDelegate>)delegate;

+ (CGFloat)getCellHeightForSingleLineText;
+ (CGFloat)getCellHeightForText:(NSString *)text;
+ (CGFloat)getCellHeightForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle;

+ (NSString *)getCellIdentifier;

- (void)setCellText:(NSString *)text
           position:(CellRowPosition)position
              group:(PBGroup *)group;

- (void)setCellForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle
                      position:(CellRowPosition)position
                       inGroup:(PBGroup *)group;

@end
