//
//  OpusCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "PPTableViewCell.h"
#import "DrawFeed.h"

#define MAX_OPUSES_EACH_CELL 4

#define OPUS_VIEW_WIDTH 80
#define OPUS_VIEW_HEIGHT 76


@protocol OpusCellDelegate <NSObject>

- (void)didClickOpus:(DrawFeed *)opus;

@end

@interface OpusCell : PPTableViewCell

- (void)setCellData:(NSArray *)opuses;

@end
