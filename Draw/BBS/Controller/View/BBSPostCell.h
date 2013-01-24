//
//  BBSPostCell.h
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "BBSTableViewCell.h"
#import "BBSModelExt.h"


@protocol BBSPostCellDelegate <BBSTableViewCellDelegate>

@optional
- (void)didClickSupportButtonWithPost:(PBBBSPost *)post;
- (void)didClickReplyButtonWithPost:(PBBBSPost *)post;

@end

@interface BBSPostCell : BBSTableViewCell
{
    PBBBSPost *_post;
    id<BBSPostCellDelegate> _delegate;
}

@property (retain, nonatomic) IBOutlet UIButton *support;
@property (retain, nonatomic) IBOutlet UIButton *comment;
@property (retain, nonatomic) IBOutlet UIButton *reward;
@property (retain, nonatomic) IBOutlet UIButton *topFlag;
@property (retain, nonatomic) PBBBSPost *post;

- (IBAction)clickSupportButton:(id)sender;
- (IBAction)clickCommentButton:(id)sender;


+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post;
- (void)updateCellWithBBSPost:(PBBBSPost *)post;

@end
