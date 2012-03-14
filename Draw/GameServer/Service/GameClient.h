//
//  GameClient.h
//  Draw
//
//  Created by  on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"

@interface GameClient : CommonNetworkClient<CommonNetworkClientDelegate>
{
    int _messageIdIndex;
}

+ (GameClient*)defaultInstance;
- (void)start:(NSString*)serverAddress port:(int)port;

- (void)sendJoinGameRequest:(NSString*)userId nickName:(NSString*)nickName;
- (void)sendStartGameRequest:(NSString*)userId sessionId:(long)sessionId;

@end
