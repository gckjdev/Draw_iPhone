//
//  DrawGameService.h
//  Draw
//
//  Created by  on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"
#import "GameNetworkClient.h"

@class GameMessage;
@protocol DrawGameServiceDelegate <NSObject>

@optional;
- (void)didReceiveDrawData:(GameMessage *)message;
- (void)didReceiveRedrawResponse:(GameMessage *)message;


@end

@interface DrawGameService : CommonService<CommonNetworkClientDelegate>
{
    GameNetworkClient *_networkClient;
    
    NSString *_userId;
    int _sessionId;
}

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, assign) id<DrawGameServiceDelegate> drawDelegate;
+ (DrawGameService*)defaultService;

- (void)sendDrawDataRequestWithPointList:(NSArray*)pointList 
                                   color:(int)color
                                   width:(float)width;

- (void)cleanDraw;

@end
