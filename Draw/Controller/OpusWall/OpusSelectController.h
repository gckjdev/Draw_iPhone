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

@interface OpusSelectController : PPTableViewController <FeedServiceDelegate , OpusCellDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *selectedOpusesHolderView;




@end
