//
//  ZJHRoomListCell.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "CommonRoomListCell.h"
#import "PPTableViewCell.h"
#import "CommonRoundAvatarView.h"
#import "GameConstants.pb.h"

@class PBGameSession;
@class PPViewController;

@interface ZJHRoomListCell : CommonRoomListCell <CommonRoundAvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;

- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile;

@end
