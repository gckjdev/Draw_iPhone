//
//  UserSettingCell.h
//  Draw
//
//  Created by Kira on 13-4-11.
//
//

#import "PPTableViewCell.h"

@interface UserSettingCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UILabel *customDetailLabel;
@property (retain, nonatomic) IBOutlet UILabel *customTextLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIImageView *customSeparatorLine;
@property (retain, nonatomic) IBOutlet UIImageView *customAccessory;

- (void)setCellWithRow:(int)row inSectionRowCount:(int)rowCount;

@end
