//
//  OpusImageBrower.h
//  Draw
//
//  Created by 王 小涛 on 13-7-12.
//
//

#import <UIKit/UIKit.h>
#import "DrawFeed.h"
#import "PageScrollViewFactory.h"

@class OpusImageBrower;

@protocol OpusImageBrowerDelegate <NSObject>

@optional
- (void)brower:(OpusImageBrower *)brower didSelecteFeed:(DrawFeed *)feed;

@end

@interface OpusImageBrower : UIView<UIGestureRecognizerDelegate, PageScrollViewDatasource, PageScrollViewDelegate>
{
    BOOL _isReplaying;
}

@property (assign, nonatomic) id<OpusImageBrowerDelegate> delegate;
@property (retain, nonatomic) PPViewController *superViewController;

- (id)initWithFeedList:(NSArray *)feedList;
- (void)setIndex:(int)index;
- (void)showInView:(UIView *)view;

- (void)showInViewController:(PPViewController *)viewController;

@end
