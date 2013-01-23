//
//  CommonRoomListCell.m
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "CommonRoomListCell.h"
#import "GameBasic.pb.h"
#import "ImageManagerProtocol.h"


@implementation CommonRoomListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellInfo:(PBGameSession *)session
{
    [self.backgroundImageView setImage:[[GameApp getImageManager] roomListCellBgImage]];
}

- (void)dealloc {
    [_roomNameLabel release];
    [_backgroundImageView release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
