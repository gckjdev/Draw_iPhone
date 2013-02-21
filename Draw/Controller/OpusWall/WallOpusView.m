//
//  WallOpusView.m
//  Draw
//
//  Created by 王 小涛 on 13-2-21.
//
//

#import "WallOpusView.h"
#import "AutoCreateViewByXib.h"
#import "UIButton+WebCache.h"

@interface WallOpusView()
@property (retain, nonatomic) PBWallOpus *wallOpus;

@end

@implementation WallOpusView

AUTO_CREATE_VIEW_BY_XIB(WallOpusView);

- (void)dealloc {
    [_wallOpus release];
    
    [_frameButton release];
    [_opusButton release];
    
    [super dealloc];
}


+ (id)createViewWithWallOpus:(PBWallOpus *)wallOpus
{
    WallOpusView *view = [self createView];
    [view updateViewWithWallOpus:wallOpus];
    return view;
}

- (void)updateViewWithWallOpus:(PBWallOpus *)wallOpus
{
    [self.frameButton setImageWithURL:[NSURL URLWithString:wallOpus.frame.imageUrl]];
    [self.opusButton setImageWithURL:[NSURL URLWithString:wallOpus.opus.opusImage]];
    self.wallOpus = wallOpus;
}

- (IBAction)clickWallOpusButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickWallOpus:)]) {
        [_delegate didClickWallOpus:_wallOpus];
    }
}




@end
