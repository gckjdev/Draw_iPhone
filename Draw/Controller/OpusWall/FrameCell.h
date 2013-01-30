//
//  FrameCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-28.
//
//

#import "PPTableViewCell.h"
#import "Draw.pb.h"

#define MAX_FRAMES_EACH_CELL 3

@protocol FrameCell <NSObject>

- (void)didClickFrame:(PBFrame *)frame;

@end

@interface FrameCell : PPTableViewCell

- (void)setCellData:(NSArray *)frames;


@end
