//
//  DraftCell.h
//  Draw
//
//  Created by 王 小涛 on 13-1-7.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "MyPaint.h"

#define MAX_DRAFT_COUNT_PER_CELL 3

@protocol DraftCellDelegate <NSObject>

@required
- (void)didClickDraft:(MyPaint *)draft;

@end

@interface DraftCell : PPTableViewCell

- (void)setCellInfo:(NSArray *)drafts;

@end
