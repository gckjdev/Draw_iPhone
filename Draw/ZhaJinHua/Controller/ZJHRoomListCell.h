//
//  ZJHRoomListCell.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "CommonRoomListCell.h"
#import "PPTableViewCell.h"
#import "DiceAvatarView.h"
#import "GameConstants.pb.h"

@class PBGameSession;
@class PPViewController;

@interface ZJHRoomListCell : CommonRoomListCell <DiceAvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (void)setCellInfo:(PBGameSession *)session;

@end