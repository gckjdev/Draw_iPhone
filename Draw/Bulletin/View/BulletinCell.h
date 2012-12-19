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

+ (BulletinCell*)createCell:(id)delegate;
- (void)setCellByBulletin:(Bulletin*)bulletin;

@end
