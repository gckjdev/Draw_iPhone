//
//  DrawRecoveryService.h
//  Draw
//
//  Created by qqn_pipi on 13-1-16.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@class MyPaint;
@class Word;

@interface DrawRecoveryService : CommonService
{
    MyPaint* _currentPaint;
}

- (int)recoveryDrawCount;

- (void)start:(NSString *)targetUid
     contestId:(NSString *)contestId
        userId:(NSString *)userId
      nickName:(NSString *)nickName
          word:(Word *)word
      language:(NSInteger)language;

- (void)backup:(NSData*)drawData;
- (void)stop;

@end
