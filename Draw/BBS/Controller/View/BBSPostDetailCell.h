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
- (void)didClickOnlySeeMe:(NSString *)targetUid;
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
@property (retain, nonatomic) IBOutlet UIButton *topFlag;
@property (retain, nonatomic) IBOutlet UIButton *markedFlag;

//只看LZ
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) IBOutlet UIButton *seeMeOnly;
- (IBAction)clickSeeMeOnly:(id)sender;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;

//use text view to show post info
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
                         inTextView:(UITextView *)textView;

// deprecated method: use label to show post.
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post;

- (void)updateCellWithBBSPost:(PBBBSPost *)post;

@end
