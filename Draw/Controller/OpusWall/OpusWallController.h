//
//  OpusWallController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "PPViewController.h"
#import "DrawFeed.h"
#import "Wall.h"
#import "OpusSelectController.h"
#import "FrameSelectController.h"
#import "WallService.h"
#import "ChangeAvatar.h"
#import "iCarousel.h"
#import "WallOpusView.h"


@interface OpusWallController : PPViewController <UIActionSheetDelegate, OpusSelectControllerDelegate, FrameSelectControllerDelegate, WallServiceDelegate, ChangeAvatarDelegate, iCarouselDataSource, iCarouselDelegate, WallOpusViewDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet iCarousel *iCarouselView;

- (id)initWithWall:(Wall *)wall;

@end
