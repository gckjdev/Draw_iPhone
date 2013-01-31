//
//  OpusSelectController.h
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "PPTableViewController.h"
#import "FeedService.h"
#import "OpusCell.h"

@class OpusSelectController;

@protocol OpusSelectControllerDelegate <NSObject>

- (void)didController:(OpusSelectController *)contorller clickOpus:(DrawFeed *)opus;

@end

@interface OpusSelectController : PPTableViewController <FeedServiceDelegate, OpusViewProtocol>
@property (retain, nonatomic) IBOutlet UIButton *comfirmBtn;

@property (retain, nonatomic) IBOutlet UIScrollView *selectedOpusesHolderView;
@property (assign, nonatomic) id<OpusSelectControllerDelegate> delegate;

- (void)hideComfirmButton;

@end
