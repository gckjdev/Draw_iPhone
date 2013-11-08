//
//  BulletinManager.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import <Foundation/Foundation.h>
#import "PPConfigManager.h"

#define MAX_CACHE_BULLETIN_COUNT    ([PPConfigManager maxCacheBulletinCount])

@class Bulletin;

@interface BulletinManager : NSObject {
    NSMutableArray* _bulletinStack;
}

+ (BulletinManager*)defaultManager;

- (NSString*)latestBulletinId;
- (void)saveBulletinList:(NSArray*)bulletinList;
- (void)pushBulletin:(Bulletin*)bulletin;
- (NSArray*)bulletins;
- (void)readAllBulletins;
- (NSInteger)unreadBulletinCount;
@end
