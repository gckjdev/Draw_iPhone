//
//  OpusCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "PPTableViewCell.h"
#import "DrawFeed.h"
#import "OpusView.h"

#define EACH_CELL_OPUSES_COUNT 4

//@protocol OpusCellDelegate <NSObject>
//
//- (void)didClickOpus:(DrawFeed *)opus;
//
//@end

@interface OpusCell : PPTableViewCell <OpusViewProtocol>

- (void)setCellData:(NSArray *)opuses delegate:(id<OpusViewProtocol>)delegate;

@end
