//
//  RouterService.m
//  Draw
//
//  Created by  on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RouterService.h"
#import "GameNetworkRequest.h"
#import "GameNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "TrafficServerManager.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "Reachability.h"

#define ROUTER_SERVER_URL   @"http://www.place100.com:8600/api/?"
//#define ROUTER_SERVER_URL   @"http://106.187.89.232:8600/api/?"

@implementation RouterService

static RouterService* _defaultRouterService;

@synthesize updateTimer = _updateTimer;
@synthesize failureServerList = _failureServerList;

- (void)dealloc
{
    [_failureServerList release];
    [_updateTimer release];
    [super dealloc];
}

+ (RouterService*)defaultService
{
    if (_defaultRouterService == nil)
        _defaultRouterService = [[RouterService alloc] init];
    
    return _defaultRouterService;
}

- (id)init
{
    self = [super init];
    self.failureServerList = [[[NSMutableArray alloc] init] autorelease];
    return self;
}

- (void)fetchServerList:(id<RouterServiceDelegate>)delegate
{
    PPDebug(@"<fetchServerList> ...");
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GameNetworkRequest getAllTrafficeServers:ROUTER_SERVER_URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == 0){            
                NSArray* jsonArray = output.jsonDataArray;
                TrafficServerManager* manager = [TrafficServerManager defaultManager];
                
                if ([jsonArray count] > 0){
                    [manager clearAllServers];
                }
                
                for (NSDictionary* server in jsonArray){
                    [manager createTrafficServer:[server objectForKey:PARA_SERVER_ADDRESS] 
                                            port:[[server objectForKey:PARA_SERVER_PORT] intValue]
                                        language:[[server objectForKey:PARA_SERVER_LANGUAGE] intValue]];
                }
            }
            
            if ([delegate respondsToSelector:@selector(didServerListFetched:)]){
                [delegate didServerListFetched:output.resultCode];
            }
        });
    });
}

- (void)fetchServerListAtBackground
{
    [self fetchServerList:nil];
}

- (void)tryFetchServerList:(id<RouterServiceDelegate>)delegate
{
    if ([[TrafficServerManager defaultManager] hasData]){
        if ([delegate respondsToSelector:@selector(didServerListFetched:)]){
            [delegate didServerListFetched:0];
        }
        return;
    }
    
    [self fetchServerList:delegate];
}

- (void)stopUpdateTimer
{
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)startUpdateTimer
{
    [self fetchServerListAtBackground];
    
    if (self.updateTimer != nil){
        [self stopUpdateTimer];
    }
    
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:60*10
                                                        target:self 
                                                      selector:@selector(fetchServerListAtBackground) 
                                                      userInfo:nil 
                                                       repeats:YES];    
}


#define LOW_USAGE_THREADHOLD 500    // 5%
#define MAX_USAGE            7000   // 70%


- (RouterTrafficServer*)assignTrafficServer
{        
    int language = [[UserManager defaultManager] getLanguageType];
    TrafficServerManager* manager = [TrafficServerManager defaultManager];

    NSArray* serverList = [manager findAllTrafficServers];
    NSMutableArray* candidateList = [[[NSMutableArray alloc] init] autorelease];
    
    // create candidate server list
    for (RouterTrafficServer* server in serverList){
        if ([[server language] intValue] == language){            
            [candidateList addObject:server];
        }
    }
    
    if ([candidateList count] == 0)
        return nil;
    
    int randomSelect = rand() % [candidateList count];
    return [candidateList objectAtIndex:randomSelect];
    
    /* rem by Benson, use random assignment now
    NSMutableArray* lowCandidateList = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray* normalCandidateList = [[[NSMutableArray alloc] init] autorelease];
    
    // create candidate server list
    for (TrafficServer* server in serverList){
        if ([server language] == language && 
            [server usage] <= MAX_USAGE &&
            [_failureServerList containsObject:[server key]] == NO){
            
            if ([server usage] < LOW_USAGE_THREADHOLD){
                [lowCandidateList addObject:server];
            }
            else{
                [normalCandidateList addObject:server];
            }
        }
    }

    TrafficServer* selectedServer = nil;
    
    BOOL disableRandom = YES;
    srand(time(0));
    if ([lowCandidateList count] > 0){
        // select the last one from low candidate server list
        if ([lowCandidateList count] == 1){
            selectedServer = [lowCandidateList objectAtIndex:0];
        }
        else{
            int randIndex = rand() % 2;
            if (disableRandom){
                randIndex = 1;
            }
            int index = [lowCandidateList count] - randIndex - 1;        // randome select one out of last 2
            selectedServer = [lowCandidateList objectAtIndex:index];
        }
        
        PPDebug(@"Choose server in low candidate, %@", [selectedServer description]);
    }    
    else if ([normalCandidateList count] > 0){
        // select the first one from normal candidate server list
        if ([normalCandidateList count] == 1){
            selectedServer = [normalCandidateList objectAtIndex:0];
        }
        else{
            int randIndex = rand() % 2;
            if (disableRandom){
                randIndex = 1;
            }
            int index = randIndex;    // randome select one out of the first 2
            selectedServer = [normalCandidateList objectAtIndex:index];
        }
                
        PPDebug(@"Choose server in normal candidate, %@", selectedServer);
    }
     
     return selectedServer;
    */
    
    
}

//- (void)putServerInFailureList:(NSString*)serverAddress port:(int)port
//{
//    NSString* key = [TrafficServer keyWithServerAddress:serverAddress port:port];
//    PPDebug(@"<putServerInFailureList> key = %@", key);
//    [_failureServerList addObject:key];
//}

@end
