//
//  DrawRoomListCell.h
//  Draw
//
//  Created by Kira on 13-1-22.
//
//

#import "CommonRoomListCell.h"
#import "DiceAvatarView.h"

@interface DrawRoomListCell : CommonRoomListCell <DiceAvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile;

@end
