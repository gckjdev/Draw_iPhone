//
//  BBSPostDetailCell.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "PPTableViewCell.h"
#import "BBSModelExt.h"

@interface BBSPostDetailCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *textContent;
@property (retain, nonatomic) IBOutlet UIImageView *imageContent;
@property (retain, nonatomic) IBOutlet UILabel *time;


+ (BBSPostDetailCell *)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
//+ (CGFloat)getCellHeight;
+ (CGFloat)getCellHeightWithPost:(PBBBSPost *)post;
- (void)updateCellWithPost:(PBBBSPost *)post;

@end
