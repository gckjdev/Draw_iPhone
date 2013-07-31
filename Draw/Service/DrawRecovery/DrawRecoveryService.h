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
@class PBDrawBg;
@class PBUserBasicInfo;

@interface DrawRecoveryService : CommonService
{
    int     _newPaintCount;
    int     _lastBackupTime;
}

@property (nonatomic, retain) MyPaint* currentPaint;
@property (nonatomic, retain) PBUserBasicInfo *drawToUser;
@property (nonatomic, assign) CGSize canvasSize;
@property (nonatomic, assign) NSArray * layers;
//@property (nonatomic, retain) MyPaint* currentPaint;
//@property (nonatomic, retain) MyPaint* currentPaint;

+ (DrawRecoveryService*)defaultService;
- (void)changeCanvasSize:(CGSize)canvasSize;
- (int)recoveryDrawCount;

- (void)start:(NSString *)targetUid
     contestId:(NSString *)contestId
        userId:(NSString *)userId
      nickName:(NSString *)nickName
          word:(Word *)word
      language:(NSInteger)language
   canvasSize:(CGSize)canvasSize
drawActionList:(NSArray*)drawActionList
  bgImageName:(NSString *)bgImageName
      bgImage:(UIImage *)bgImage;

//- (void)backup:(PBNoCompressDrawData*)drawData;
- (void)backup:(NSArray*)drawActionList;
- (void)stop;

- (int)backupInterval;

- (void)handleTimer:(NSArray*)drawActionList;
- (void)handleNewPaintDrawed:(NSArray*)drawActionList;

- (void)updateTargetUid:(NSString *)tUid;


@end
