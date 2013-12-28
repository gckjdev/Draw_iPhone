//
//  BBSPostActionCell.h
//  Draw
//
//  Created by gamy on 12-11-21.
//
//

#import "BBSTableViewCell.h"
#import "BBSPopupSelectionView.h"

@class PBBBSAction;

@protocol BBSPostActionCellDelegate <BBSTableViewCellDelegate>

@optional
- (void)didClickReplyButtonWithAction:(PBBBSAction *)action;
- (void)didClickPayButtonWithAction:(PBBBSAction *)action;
- (void)didClickOnlySeeMe:(NSString *)targetUid;

@end

@interface BBSPostActionCell : BBSTableViewCell<BBSOptionViewDelegate>
{
    

}

@property (retain, nonatomic) IBOutlet UIButton *reply;
@property (retain, nonatomic) IBOutlet UIImageView *option;
@property (retain, nonatomic) IBOutlet UIImageView *supportImage;

@property (retain, nonatomic) PBBBSAction *action;
@property (retain, nonatomic) PBBBSPost *post;

//只看用户
@property (retain, nonatomic) NSString *currentUserId;
@property (retain, nonatomic) IBOutlet UIButton *seeMeOnly;
@property (assign, nonatomic) BOOL hideReply;
- (IBAction)clickSeeMeOnly:(id)sender;

- (IBAction)clickRepyButton:(id)sender;
+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;

+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action inTextView:(UITextView *)textView;
// deprecated method
+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action;

- (void)updateCellWithBBSAction:(PBBBSAction *)action post:(PBBBSPost *)post;
- (void)showOption:(BOOL)show;


@end
