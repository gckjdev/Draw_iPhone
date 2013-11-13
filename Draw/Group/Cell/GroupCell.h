//
//  GroupCell.h
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "PPTableViewCell.h"
#import "Group.pb.h"


@interface GroupCell : PPTableViewCell

@property(nonatomic, assign)PBGroup *group;

+ (GroupCell *)createCell:(id)delegate;
+ (CGFloat)getCellHeight;
+ (NSString*)getCellIdentifier;

- (void)setCellInfo:(PBGroup *)group;

@end
