//
//  DrawGameService.h
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "GameNetworkClient.h"

@interface DrawGameService : CommonService<CommonNetworkClientDelegate>
{
    GameNetworkClient *_networkClient;
}


+ (DrawGameService*)defaultService;



@end
