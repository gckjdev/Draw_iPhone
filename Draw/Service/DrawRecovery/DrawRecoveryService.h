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
@property (nonatomic, retain) NSArray * layers;
@property (nonatomic, retain) NSString * targetUid;
@property (nonatomic, retain) NSString * contestId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) Word * word;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSArray* drawActionList;
@property (nonatomic, retain) NSString * bgImageName;
@property (nonatomic, retain) UIImage * bgImage;

@property (nonatomic, assign) NSInteger language;
@property (nonatomic, assign) CGSize canvasSize;


+ (DrawRecoveryService*)defaultService;
- (int)recoveryDrawCount;

- (void)backup:(NSArray*)drawActionList
     targetUid:(NSString*)targetUid
          word:(Word*)word
          desc:(NSString*)desc
    canvasSize:(CGSize)canvasSize
   bgImageName:(NSString*)bgImageName
       bgImage:(UIImage*)bgImage
     contestId:(NSString*)contestId
       strokes:(int64_t)strokes
     spendTime:(int)spendTime
  completeDate:(int)completeDate
        layers:(NSArray *)layers;

- (void)start:(NSArray*)drawActionList
    targetUid:(NSString*)targetUid
         word:(Word*)word
         desc:(NSString*)desc
   canvasSize:(CGSize)canvasSize
  bgImageName:(NSString*)bgImageName
      bgImage:(UIImage*)bgImage
    contestId:(NSString*)contestId
      strokes:(int64_t)strokes
    spendTime:(int)spendTime
 completeDate:(int)completeDate
       layers:(NSArray *)layers;

- (void)stop;
- (int)backupInterval;

- (void)handleNewPaintDrawed:(NSArray*)drawActionList
                   targetUid:(NSString*)targetUid
                        word:(Word*)word
                        desc:(NSString*)desc
                  canvasSize:(CGSize)canvasSize
                 bgImageName:(NSString*)bgImageName
                     bgImage:(UIImage*)bgImage
                   contestId:(NSString*)contestId
                     strokes:(int64_t)strokes
                   spendTime:(int)spendTime
                completeDate:(int)completeDate
                      layers:(NSArray *)layers;

- (BOOL)needBackup;

//- (void)changeCanvasSize:(CGSize)canvasSize;
/*
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
*/

//- (void)backup:(PBNoCompressDrawData*)drawData;
/*
- (void)handleTimer:(NSArray*)drawActionList;
- (void)handleNewPaintDrawed:(NSArray*)drawActionList;

- (void)updateTargetUid:(NSString *)tUid;
*/

@end
