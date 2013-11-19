//
//  GroupCell.h
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "PPTableViewCell.h"
#import "Group.pb.h"
#import "GroupInfoView.h"

@class GroupCell;
@protocol GroupCellDelegate <NSObject>

@optional
- (void)groupCell:(GroupCell *)cell goFollowGroup:(PBGroup *)group;
- (void)groupCell:(GroupCell *)cell goUnfollowGroup:(PBGroup *)group;

@end

@interface GroupCell : PPTableViewCell<GroupInfoViewDelegate>

@property(nonatomic, assign)PBGroup *group;

+ (GroupCell *)createCell:(id<GroupCellDelegate>)delegate;
+ (CGFloat)getCellHeight;
+ (NSString*)getCellIdentifier;

- (void)setCellInfo:(PBGroup *)group;

@end
