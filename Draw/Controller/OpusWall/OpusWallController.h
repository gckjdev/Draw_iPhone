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


@interface OpusWallController : PPViewController <UIActionSheetDelegate, OpusSelectControllerDelegate, FrameSelectControllerDelegate>
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *setLayoutButton;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;

- (id)initWithWall:(Wall *)wall;

@end
