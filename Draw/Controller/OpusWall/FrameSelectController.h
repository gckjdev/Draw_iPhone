//
//  FrameSelectController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-28.
//
//

#import "PPTableViewController.h"
#import "Draw.pb.h"

@class FrameSelectController;

@protocol FrameSelectControllerDelegate <NSObject>

- (void)didController:(FrameSelectController *)vc clickFrame:(PBFrame *)frame;

@end

@interface FrameSelectController : PPTableViewController
@property (assign, nonatomic) id<FrameSelectControllerDelegate> delegate;
@end
