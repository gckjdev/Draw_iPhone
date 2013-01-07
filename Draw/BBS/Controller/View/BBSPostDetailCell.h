//
//  BBSPostDetailCell.h
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "BBSTableViewCell.h"
#import "BBSModelExt.h"


@protocol BBSPostDetailCellDelegate <BBSTableViewCellDelegate>

@optional
- (void)didClickSupportButtonWithPost:(PBBBSPost *)post;
- (void)didClickReplyButtonWithPost:(PBBBSPost *)post;

@end

@interface BBSPostDetailCell : BBSTableViewCell
{
    PBBBSPost *_post;
//    id<BBSPostDetailCellDelegate> _delegate;
}

@property (retain, nonatomic) IBOutlet UIButton *reward;
@property (retain, nonatomic) PBBBSPost *post;
//@property (retain, assign) id<BBSPostDetailCellDelegate> delegate;


+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post;
- (void)updateCellWithBBSPost:(PBBBSPost *)post;

@end
