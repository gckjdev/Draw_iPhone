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

+ (id)createCell:(id<GroupDetailCellDelegate>)delegate;

+ (CGFloat)getCellHeightForSimpleText;
+ (CGFloat)getCellHeightForSingleAvatar;
+ (CGFloat)getCellHeightForMultipleAvatar:(NSInteger)avatarCount;

+ (NSString *)getCellIdentifier;

- (void)setCellText:(NSString *)text
           position:(CellRowPosition)position
              group:(PBGroup *)group;

- (void)setCellForCreatorInGroup:(PBGroup *)group;

- (void)setCellForMembers:(PBGroupUsersByTitle *)members
                 position:(CellRowPosition)position
                  InGroup:(PBGroup *)group;

@end
