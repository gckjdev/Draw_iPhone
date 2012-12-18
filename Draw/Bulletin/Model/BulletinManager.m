//
//  BulletinManager.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinManager.h"
#import "SynthesizeSingleton.h"

@implementation BulletinManager
SYNTHESIZE_SINGLETON_FOR_CLASS(BulletinManager)

+ (BulletinManager*)defaultManager
{
    return [BulletinManager sharedBulletinManager];
}

- (NSString*)latestBulletinId
{
    return nil;
}

- (void)saveBulletinList:(NSArray*)bulletinList
{
    
}

@end
