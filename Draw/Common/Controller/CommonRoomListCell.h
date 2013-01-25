//
//  CommonRoomListCell.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "PPTableViewCell.h"
@class PBGameSession;

@protocol CommonRoomListCellDelegate <NSObject>

- (void)didQueryUser:(NSString*)userId;

@end

@interface CommonRoomListCell : PPTableViewCell

@property (assign, nonatomic) id<CommonRoomListCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (void)setCellInfo:(PBGameSession *)session;

@end
