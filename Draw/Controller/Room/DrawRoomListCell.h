//
//  DrawRoomListCell.h
//  Draw
//
//  Created by Kira on 13-1-22.
//
//

#import "CommonRoomListCell.h"
#import "StableView.h"

@class FXLabel;

@interface DrawRoomListCell : CommonRoomListCell <AvatarViewDelegate>

@property (retain, nonatomic) IBOutlet FXLabel *roomNameLabel;
- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile;

@end
