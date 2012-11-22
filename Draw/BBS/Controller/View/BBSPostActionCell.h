//
//  BBSPostActionCell.h
//  Draw
//
//  Created by gamy on 12-11-21.
//
//

#import "PPTableViewCell.h"

@class PBBBSAction;

@protocol BBSPostActionCellDelegate <NSObject>

@optional
- (void)didClickReplyButtonWithAction:(PBBBSAction *)action;
- (void)didClickPayButtonWithAction:(PBBBSAction *)action;

@end

@interface BBSPostActionCell : PPTableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *content;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIButton *reply;
@property (retain, nonatomic) PBBBSAction *action;

- (IBAction)clickRepyButton:(id)sender;
- (IBAction)clickPayButton:(id)sender;
+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)post;
- (void)updateCellWithBBSAction:(PBBBSAction *)post;


@end
