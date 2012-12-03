//
//  BBSUserActionCell.h
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "BBSTableViewCell.h"
#import "BBSModelExt.h"

@interface BBSUserActionCell : BBSTableViewCell


//@property (retain, nonatomic) IBOutlet UIImageView *avatar;
//@property (retain, nonatomic) IBOutlet UILabel *nickName;
//@property (retain, nonatomic) IBOutlet UILabel *content;
//@property (retain, nonatomic) IBOutlet UILabel *timestamp;
//@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UILabel *source;
@property (retain, nonatomic) PBBBSAction *action;
@property (retain, nonatomic) IBOutlet UIImageView *supportImage;
@property (retain, nonatomic) IBOutlet UIView *splitLine;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)post;
- (void)updateCellWithBBSAction:(PBBBSAction *)post;

@end
