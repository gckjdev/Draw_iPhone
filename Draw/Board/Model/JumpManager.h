//
//  JumpManager.h
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JumpHandler.h"


@class BoardView;
@interface JumpManager : NSObject

+ (JumpManager *)defaultManager;

- (void)JumpBoardView:(BoardView *)boardView 
       controller:(UIViewController *)controller 
          request:(NSURL *)URL;

//is handled by the board view self?
- (BOOL)innerJump:(NSURL *)URL;


@end
