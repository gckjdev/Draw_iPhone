//
//  JumpManager.m
//  Draw
//
//  Created by  on 12-8-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "JumpManager.h"


@interface JumpManager(){
    
}
//- (void)handleGameJump:(NSURL *)URL 

@end

JumpManager *_staticJumpManager = nil;

@implementation JumpManager


- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (JumpManager *)defaultManager
{
    if (_staticJumpManager == nil) {
        _staticJumpManager = [[JumpManager alloc] init];
    }
    return _staticJumpManager;
}


- (JumpType)typeForURL:(NSURL *)URL
{
    NSDictionary *dict = [URL queryComponents];
    NSString *typeString = [dict objectForKey:BOARD_PARA_TYPE];
    return [typeString integerValue];
}

- (BOOL)legalHost:(NSURL *)URL
{
    return ([URL.host isEqualToString:BOARD_HOST]);
}



#pragma mark public method.
- (void)jumpBoardView:(BoardView *)boardView 
           controller:(UIViewController *)controller 
              request:(NSURL *)URL
{
    if (![self legalHost:URL]) {
        return;
    }
    JumpType type = [self typeForURL:URL];
    JumpHandler *jumpHandler = [JumpHandler createJumpHandlerWithType:type];
    [jumpHandler handleJump:boardView controller:controller URL:URL];    
}

//is handled by the board view self?
- (BOOL)innerJump:(NSURL *)URL
{
    NSString *scheme = URL.scheme;
    PPDebug(@"scheme = %@", scheme);
    return ([URL.scheme isEqualToString:BOARD_HTTP_SCHEME] 
            || [URL.scheme isEqualToString:BOARD_FILE_SCHEME]
            || [URL.scheme isEqualToString:BOARD_TEL_SCHEME] 
            || [URL.scheme isEqualToString:BOARD_SMS_SCHEME]);
}

@end
