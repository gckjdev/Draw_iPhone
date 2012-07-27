//
//  CommonGameNetworkClient.h
//  Draw
//
//  Created by  on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkClient.h"
#import "GameConstants.pb.h"

@interface CommonGameNetworkClient : CommonNetworkClient<CommonNetworkClientDelegate>
{
    int _messageIdIndex;    
}

+ (CommonGameNetworkClient*)defaultInstance;
- (void)start:(NSString*)serverAddress port:(int)port;


@end
