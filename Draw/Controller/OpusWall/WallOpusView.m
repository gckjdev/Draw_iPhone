//
//  WallOpusView.m
//  Draw
//
//  Created by 王 小涛 on 13-2-1.
//
//

#import "WallOpusView.h"
#import "AutoCreateViewByXib.h"

@implementation WallOpusView

AUTO_CREATE_VIEW_BY_XIB(WallOpusView);

+ (id)createViewWithRect:(CGRect)rect pbFrame:(PBFrame *)pbFrame
{
    WallOpusView *view  = [self createView];
    view.frame = rect;
    
    PBRect *pbRect = [DeviceDetection isIPAD] ? pbFrame.iPadRect : pbFrame.iPhoneRect;

    CGRect frameBtnRect = CGRectMake(pbRect.x, pbRect.y, pbRect.width, pbRect.height);
    view.frameButton.frame = frameBtnRect;
    
    
    
    
     
    
//    UIImageView *frameImageView  = [[[UIImageView alloc] initWithFrame:button.bounds] autorelease];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[[FrameManager sharedFrameManager] frameWithFrameId:frame.frameId] image]];
//    if (image == nil) {
//        [frameImageView setImageWithURL:[NSURL URLWithString:frame.imageUrl]];
//    }else{
//        [frameImageView setImage:image];
//    }
//    
//    [button setImage:image forState:UIControlStateNormal];
//    button.tag = wallOpus.frameIdOnWall;
//    
//    [button addTarget:self action:@selector(clickWallOpus:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    PBRect *pbOpusRect = [DeviceDetection isIPAD] ? frame.opusIpadRect : frame.opusIphoneRect;
//    CGRect opusRect = CGRectMake(pbOpusRect.x, pbOpusRect.y, pbOpusRect.width, pbOpusRect.height);
//    UIImageView *opusImageView = [[[UIImageView alloc] initWithFrame:opusRect] autorelease];
//    [opusImageView setImageWithURL:[NSURL URLWithString:[wallOpus opus].drawImageUrl]];
//    
//    [button addSubview:opusImageView];
//    
//    return button;

    
    
    return view;
    
}

- (void)dealloc {
    [_bgImageView release];
    [_frameButton release];
    [_opusImageView release];
    [super dealloc];
}
@end
