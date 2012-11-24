//
//  BBSUserActionCell.h
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "PPTableViewCell.h"
#import "BBSModelExt.h"

@interface BBSUserActionCell : PPTableViewCell


@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *content;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UILabel *source;
@property (retain, nonatomic) PBBBSAction *action;

+ (id)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)post;
- (void)updateCellWithBBSAction:(PBBBSAction *)post;

@end
