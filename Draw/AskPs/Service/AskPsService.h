//
//  AskPsService.h
//  Draw
//
//  Created by haodong on 13-6-14.
//
//

#import "CommonService.h"

@protocol AskPsServiceDelegate <NSObject>

@optional
- (void)didAwardIngot:(int)resultCode;

@end

@interface AskPsService : CommonService

+ (AskPsService*)defaultService;

- (void)awardIngot:(id<AskPsServiceDelegate>)delegate
            userId:(NSString *)userId;

@end
