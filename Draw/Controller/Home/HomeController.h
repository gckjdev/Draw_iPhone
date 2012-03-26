//
//  HomeController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DrawGameService.h"

@interface HomeController : PPViewController<DrawGameServiceDelegate>
{
    BOOL _isTryJoinGame;
}

- (IBAction)clickStart:(id)sender;
- (IBAction)clickShop:(id)sender;
+ (HomeController *)defaultInstance;
+ (void)returnRoom:(UIViewController*)superController;
@end
