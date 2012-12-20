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
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel *contentLabel;
@property (retain, nonatomic) IBOutlet UIImageView *dateBgView;
@property (retain, nonatomic) IBOutlet UIButton *timeButton;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UIImageView *newBulletinFlag;

+ (BulletinCell*)createCell:(id)delegate;
- (void)setCellByBulletin:(Bulletin*)bulletin;
+ (CGSize)cellSizeForContent:(NSString*)content;

@end
