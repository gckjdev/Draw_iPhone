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

@class GroupDetailCell;
@protocol GroupDetailCellDelegate <NSObject>

- (void)groupDetailCell:(GroupDetailCell *)cell
        didClickCreator:(PBGameUser *)user;


- (void)groupDetailCell:(GroupDetailCell *)cell
           didClickUser:(PBGameUser *)user
                  title:(PBGroupTitle *)title;

- (void)groupDetailCell:(GroupDetailCell *)cell
didClickAddButtonAtTitle:(PBGroupTitle *)title;

- (void)groupDetailCell:(GroupDetailCell *)cell
        didClickAtTitle:(PBGroupTitle *)title;


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

+ (CGFloat)getCellHeightForSingleAvatar;
+ (CGFloat)getCellHeightForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle;

+ (NSString *)getCellIdentifier;

- (void)setCellText:(NSString *)text
           position:(CellRowPosition)position
              group:(PBGroup *)group;

- (void)setCellForCreatorInGroup:(PBGroup *)group
                        position:(CellRowPosition)position;

- (void)setCellForAdminsInGroup:(PBGroup *)group
                        position:(CellRowPosition)position;


- (void)setCellForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle
                      position:(CellRowPosition)position
                       inGroup:(PBGroup *)group;

@end
