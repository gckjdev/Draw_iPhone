//
//  HomeHeaderView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"

@protocol HomeHeaderPanelDelegate <HomeCommonViewDelegate>

@optional
- (void)didClickChargeButton:(UIButton *)button;

@end

@interface HomeHeaderPanel : HomeCommonView<HomeCommonViewProtocol>
{
    
}

@end
