//
//  BBSPostDetailCell.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "PPTableViewCell.h"
#import "Bbs.pb.h"

@interface BBSPostDetailCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *textContent;
@property (retain, nonatomic) IBOutlet UIImageView *imageContent;


+ (BBSPostDetailCell *)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
- (void)updateCellWithPost:(PBBBSPost *)post;

@end
