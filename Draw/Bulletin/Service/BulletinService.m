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

@implementation BulletinService

SYNTHESIZE_SINGLETON_FOR_CLASS(BulletinService)

+ (BulletinService*)defaultService
{
    return [BulletinService sharedBulletinService];
}

- (void)syncBulletins
{
    dispatch_async(workingQueue, ^{
        DeviceType deviceType = [DeviceDetection deviceType];
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
        PPDebug(@"<didGetBoards> result code = %d", errorCode);
        if (errorCode == ERROR_SUCCESS && [output.jsonDataArray count] != 0) {
            NSMutableArray * unSortedBoardList = [NSMutableArray array];
            for (NSDictionary *dict in output.jsonDataArray) {
                
            }
            //sort the boardList by the index
            bulletinList = [unSortedBoardList sortedArrayUsingComparator:^(id obj1,id obj2){
                return NSOrderedSame;
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errorCode == 0) {
                [[BulletinManager defaultManager] saveBulletinList:bulletinList];
                
                // post notifcation here, for UI to update
//                [self postNotification:BOARD_UPDATE_NOTIFICATION];
//                [self stopLoadBoardTimer];
            }else {
                // failure, do nothing
            }
        });
        
    });
}

@end
