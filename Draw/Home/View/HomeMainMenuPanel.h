//
//  HomeMainMenuView.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <UIKit/UIKit.h>
#import "HomeCommonView.h"
#import "HomeMenuView.h"

@interface HomeMainMenuPanel : HomeCommonView<HomeCommonViewProtocol, UIScrollViewDelegate, HomeMenuViewDelegate>
{
    
}
- (void)updateMenu:(HomeMenuType)type badge:(NSInteger)badge;
@end
