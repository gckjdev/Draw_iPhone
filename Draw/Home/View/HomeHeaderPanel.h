//
//  HomeHeaderView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"
#import "FeedService.h"

@class HomeHeaderPanel;
@class DrawFeed;

@protocol HomeHeaderPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickChargeButton:(UIButton *)button;

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickAvatarButton:(UIButton *)button;

- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickDrawImage:(DrawFeed *)drawFeed;

@end

@interface HomeHeaderPanel : HomeCommonView<HomeCommonViewProtocol, FeedServiceDelegate>
{
    
}

@end