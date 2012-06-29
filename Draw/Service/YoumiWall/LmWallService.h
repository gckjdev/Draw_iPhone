//
//  LmWallService.h
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LmmobAdWallSDK/LmmobAdWallSDK.h>

@interface LmWallService : NSObject<LmmobAdWallDelegate>
{
    UIViewController* _viewController;
}

+ (LmWallService*)defaultService;
- (void)show:(UIViewController*)viewController;
- (void)queryScore;

@end
