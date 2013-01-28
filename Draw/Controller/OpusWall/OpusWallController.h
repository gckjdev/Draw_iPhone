//
//  OpusWallController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "PPViewController.h"
#import "Draw.pb.h"
#import "DrawFeed.h"

@interface OpusWallController : PPViewController
@property (retain, nonatomic) IBOutlet UIButton *backButton;

- (id)initWithWall:(PBWall *)wall;

@end
