//
//  BulletinService.h
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "CommonService.h"

@interface BulletinService : CommonService

+ (BulletinService*)defaultService;


- (void)syncBulletins;

@end
