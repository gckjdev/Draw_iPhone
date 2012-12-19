//
//  BulletinService.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinService.h"
#import "BulletinNetwork.h"
#import "SynthesizeSingleton.h"
#import "ConfigManager.h"
#import "UserManager.h"
#import "BulletinManager.h"
#import "BulletinNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "Bulletin.h"
#import "NotificationManager.h"
#import "StatisticManager.h"



@implementation BulletinService

SYNTHESIZE_SINGLETON_FOR_CLASS(BulletinService)

+ (BulletinService*)defaultService
{
    return [BulletinService sharedBulletinService];
}

- (void)postNotification:(NSString*)name
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:name
     object:self
     userInfo:nil];
    
    PPDebug(@"<%@> post notification %@", [self description], name);
}

- (void)syncBulletins
{
    dispatch_async(workingQueue, ^{
        NSString *appId = [ConfigManager appId];
        NSString *gameId = [ConfigManager gameId];
        NSString *userId = [[UserManager defaultManager] userId];
        NSString *bulletinId = [[BulletinManager defaultManager] latestBulletinId];
        
        CommonNetworkOutput *output = [BulletinNetwork getBulletins:TRAFFIC_SERVER_URL
                                                              appId:appId
                                                             gameId:gameId
                                                             userId:userId
                                                         bulletinId:bulletinId];
        NSInteger errorCode = output.resultCode;
        NSArray *bulletinList = nil;
        PPDebug(@"<didGetBulletins> result code = %d", errorCode);
        if (errorCode == ERROR_SUCCESS && [output.jsonDataArray count] != 0) {
            NSMutableArray* unSortedBulletinList = [[[NSMutableArray alloc] initWithCapacity:MAX_CACHE_BULLETIN_COUNT] autorelease];
            for (NSDictionary *dict in output.jsonDataArray) {
                Bulletin* bulletin = [[[Bulletin alloc] initWithDict:dict] autorelease];
                [[BulletinManager defaultManager] pushBulletin:bulletin];
            }
            //sort the boardList by the index
            bulletinList = [unSortedBulletinList sortedArrayUsingComparator:^(id obj1,id obj2){
                Bulletin* bulletin1 = (Bulletin*)obj1;
                Bulletin* bulletin2 = (Bulletin*)obj2;
                if (bulletin1.date.timeIntervalSince1970 > bulletin2.date.timeIntervalSince1970) {
                    return NSOrderedAscending;
                } else if (bulletin1.date.timeIntervalSince1970 > bulletin2.date.timeIntervalSince1970) {
                    return NSOrderedDescending;
                }
                return NSOrderedSame;
            }];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == ERROR_SUCCESS) {
                [[BulletinManager defaultManager] saveBulletinList:bulletinList];
                [[StatisticManager defaultManager] setBulletinCount:bulletinList.count];
                
            }else {
                // failure, do nothing
            }
        });
        
//        [self postNotification:BULLETIN_UPDATE_NOTIFICATION];
        
    });
}

- (NSArray*)bulletins
{
    return [BulletinManager defaultManager].bulletins;
}

@end
