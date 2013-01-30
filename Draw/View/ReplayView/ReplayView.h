//
//  ReplayView.h
//  Draw
//
//  Created by  on 12-9-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShowDrawView.h"
#import "PPViewController.h"

@interface ReplayView : UIView<ShowDrawViewDelegate>
{

}


+ (id)createReplayView;
- (void)showInController:(PPViewController *)controller
          withActionList:(NSMutableArray *)actionList
            isNewVersion:(BOOL)isNewVersion;
@end
