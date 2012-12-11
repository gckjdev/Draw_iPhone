//
//  HomeHeaderView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"


@class HomeHeaderPanel;

@protocol HomeHeaderPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)homeHeaderPanel:(HomeHeaderPanel *)headerPanel
   didClickChargeButton:(UIButton *)button;

@end

@interface HomeHeaderPanel : HomeCommonView<HomeCommonViewProtocol>
{
    
}

@end
