//
//  BulletinCell.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@class Bulletin;

@interface BulletinCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *newBulletinFlag;
@property (retain, nonatomic) IBOutlet UIImageView *customAccessoryImageView;
@property (retain, nonatomic) IBOutlet UIView *contentHolderView;

+ (BulletinCell*)createCell:(id)delegate;
- (void)setCellByBulletin:(Bulletin*)bulletin;
+ (CGSize)cellSizeForContent:(NSString*)content;

@end
