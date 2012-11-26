//
//  BBSPostActionCell.h
//  Draw
//
//  Created by gamy on 12-11-21.
//
//

#import "BBSTableViewCell.h"

@class PBBBSAction;

@protocol BBSPostActionCellDelegate <BBSTableViewCellDelegate>

@optional
- (void)didClickReplyButtonWithAction:(PBBBSAction *)action;
- (void)didClickPayButtonWithAction:(PBBBSAction *)action;

@end

@interface BBSPostActionCell : BBSTableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UIButton *reply;
@property (retain, nonatomic) PBBBSAction *action;

- (IBAction)clickRepyButton:(id)sender;
- (IBAction)clickPayButton:(id)sender;
+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)post;
- (void)updateCellWithBBSAction:(PBBBSAction *)post;


@end
