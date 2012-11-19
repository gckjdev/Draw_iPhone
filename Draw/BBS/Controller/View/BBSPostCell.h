//
//  BBSPostCell.h
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "PPTableViewCell.h"
#import "Bbs.pb.h"

@interface BBSPostCell : PPTableViewCell
{
    PBBBSPost *_post;
}
@property (retain, nonatomic) IBOutlet UIImageView *avatar;

@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *content;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIButton *support;
@property (retain, nonatomic) IBOutlet UIButton *comment;
@property (retain, nonatomic) IBOutlet UILabel *reward;
@property (retain, nonatomic) PBBBSPost *post;

- (IBAction)clickSupportButton:(id)sender;
- (IBAction)clickCommentButton:(id)sender;


+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post;
- (void)updateCellWithBBSPost:(PBBBSPost *)post;

@end
