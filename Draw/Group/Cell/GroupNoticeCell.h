//
//  GroupNoticeCell.h
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "PPTableViewCell.h"
#import "StableView.h"

@class PBGroupNotice;

@interface GroupNoticeCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet AvatarView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *notice;
@property (retain, nonatomic) IBOutlet UILabel *message;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) PBGroupNotice *groupNotice;

- (void)setCellInfo:(PBGroupNotice *)groupNotice;
+ (CGFloat)getCellHeightByNotice:(PBGroupNotice *)groupNotice;
@end
