//
//  SongTagCell.h
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import "PPTableViewCell.h"
#import "Sing.pb.h"

#define TagsPerCell 4.0f

@protocol SongTagCellDelegate <NSObject>

@optional
- (void)didClickTag:(NSString *)tag;

@end

@interface SongTagCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UILabel *categoryLabel;
@property (retain, nonatomic) IBOutlet UIImageView *seperator;

- (void)setCellInfo:(NSDictionary *)category;
+ (CGFloat)getCellHeightWithCategory:(NSDictionary *)category;

@end
