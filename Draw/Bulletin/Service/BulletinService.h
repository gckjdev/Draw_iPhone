//
//  BulletinService.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "CommonService.h"

#define BULLETIN_UPDATE_NOTIFICATION    @"BULLETIN_UPDATE_NOTIFICATION"

@interface BulletinService : CommonService

+ (BulletinService*)defaultService;

- (void)syncBulletins;

- (NSArray*)bulletins;

- (void)readAllBulletins;
- (NSInteger)unreadBulletinCount;

@end
