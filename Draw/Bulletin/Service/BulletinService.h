//
//  BulletinService.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "CommonService.h"

typedef void(^BulletinServiceCallbackBlock)(int resultCode);

#define BULLETIN_UPDATE_NOTIFICATION    @"BULLETIN_UPDATE_NOTIFICATION"

@interface BulletinService : CommonService

+ (BulletinService*)defaultService;

- (void)syncBulletins:(BulletinServiceCallbackBlock)block;

- (NSArray*)bulletins;

- (void)readAllBulletins;
- (NSInteger)unreadBulletinCount;

@end
