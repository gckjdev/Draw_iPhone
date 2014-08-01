//
//  FeedListController.h
//  Draw
//
//  Created by qqn_pipi on 14-7-1.
//
//

#import <UIKit/UIKit.h>
#import "CommonTabController.h"
#import "FeedService.h"

@class OpusClassInfo;

enum{
    FEED_DISPLAY_NORMAL = 0,
    FEED_DISPLAY_BIG3 = 1
};

@interface FeedListController : CommonTabController<FeedServiceDelegate>

@property (nonatomic, retain) OpusClassInfo* opusClassInfo;
@property (nonatomic, assign) int displayStyle;
@property (nonatomic, assign) FeedListType feedType;
@property (nonatomic, assign) UIViewController* superViewController;

- (id)initWithFeedType:(FeedListType)feedType
         opusClassInfo:(OpusClassInfo*)opusClassInfo
          displayStyle:(int)displayStyle
   superViewController:(UIViewController*)superViewController
                 title:(NSString*)title;

- (void)cleanDataBeforeRemoveView;

@end
