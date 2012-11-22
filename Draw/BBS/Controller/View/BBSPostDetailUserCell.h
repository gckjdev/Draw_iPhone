//
//  BBSPostDetailUserCell.h
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@class PBBBSUser;

@interface BBSPostDetailUserCell : PPTableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;


+ (BBSPostDetailUserCell *)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
- (void)updateCellWithUser:(PBBBSUser *)user;


@end
