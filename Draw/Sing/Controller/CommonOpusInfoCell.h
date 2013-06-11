//
//  CommonOpusInfoCell.h
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "PPTableViewCell.h"
#import "Opus.pb.h"

@protocol CommonOpusInfoCellDelegate <NSObject>

@optional
- (void)didClickOpusImageButton:(PBOpus *)opus;
- (void)didClickTargetUserButton:(PBGameUser *)user;

@end

@interface CommonOpusInfoCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIButton *opusImageButton;
@property (retain, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *targetUserButton;
@property (retain, nonatomic) IBOutlet UITextView *opusDescTextView;

- (void)setOpusInfo:(PBOpus *)opus;

// Overwrite methods below in your sub-class.
+ (CGFloat)getCellHeightWithOpus:(PBOpus *)opus;

@end
