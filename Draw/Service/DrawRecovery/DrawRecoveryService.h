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
@class PBNoCompressDrawData;

@interface DrawRecoveryService : CommonService
{
    
}

@property (nonatomic, assign) MyPaint* currentPaint;

- (int)recoveryDrawCount;

- (void)start:(NSString *)targetUid
     contestId:(NSString *)contestId
        userId:(NSString *)userId
      nickName:(NSString *)nickName
          word:(Word *)word
      language:(NSInteger)language;

- (void)backup:(PBNoCompressDrawData*)drawData;
- (void)stop;

@end
