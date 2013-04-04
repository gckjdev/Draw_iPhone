//
//  FeedCarousel.h
//  Draw
//
//  Created by 王 小涛 on 13-3-25.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "DrawFeed.h"

@protocol FeedCarouselProtocol <NSObject>

@optional
- (void)didSelectDrawFeed:(DrawFeed *)drawFeed;

@end

@interface FeedCarousel : UIView <iCarouselDataSource, iCarouselDelegate>
@property (retain, nonatomic) IBOutlet iCarousel *carousel;
@property (retain, nonatomic) IBOutlet UILabel *tipLable;
@property (assign, nonatomic) id<FeedCarouselProtocol> delegate;

+ (id)createFeedCarousel;
- (void)showActivity;
- (void)hideActivity;

- (void)setDrawFeedList:(NSArray *)drawFeeds
                tipText:(NSString *)tipText;

- (void)startScrolling;
- (void)stopScrolling;
- (void)enabaleWrap:(BOOL)wrap;

@end
