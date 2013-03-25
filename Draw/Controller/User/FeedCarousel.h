//
//  FeedCarousel.h
//  Draw
//
//  Created by 王 小涛 on 13-3-25.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface FeedCarousel : UIView <iCarouselDataSource, iCarouselDelegate>
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet iCarousel *carousel;

+ (id)createFeedCarousel;
- (void)setDrawFeedList;

@end
