//
//  WallOpusView.h
//  Draw
//
//  Created by 王 小涛 on 13-2-1.
//
//

#import <UIKit/UIKit.h>
#import "Draw.pb.h"

#define WALLOPUSVIEW_WIDTH 250
#define WALLOPUSVIEW_HEIGHT 320

@protocol WallOpusViewDelegate <NSObject>
- (void)didClickWallOpus:(PBWallOpus*)wallOpus;

@end

@interface WallOpusView : UIView

@property (assign, nonatomic) id<WallOpusViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *frameButton;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;

+ (id)createViewWithWallOpus:(PBWallOpus *)wallOpus;
- (void)updateViewWithWallOpus:(PBWallOpus *)wallOpus;

@end
