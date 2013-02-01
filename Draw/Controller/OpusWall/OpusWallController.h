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


@interface OpusWallController : PPViewController <UIActionSheetDelegate, OpusSelectControllerDelegate, FrameSelectControllerDelegate, WallServiceDelegate, ChangeAvatarDelegate>

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *setLayoutButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;

- (id)initWithWall:(Wall *)wall;

@end
