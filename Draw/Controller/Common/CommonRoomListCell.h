//
//  CommonRoomListCell.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "PPTableViewCell.h"

@protocol CommonRoomListCellDelegate <NSObject>

- (void)didQueryUser:(NSString*)userId;

@end

@interface CommonRoomListCell : PPTableViewCell

@property (assign, nonatomic) id<CommonRoomListCellDelegate> delegate;

@end
