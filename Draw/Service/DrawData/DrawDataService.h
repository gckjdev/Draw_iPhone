//
//  DrawDataService.h
//  Draw
//
//  Created by haodong qiu on 12年5月16日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "CommonService.h"
#import "PPViewController.h"
#import "DrawAction.h"
#import "Word.h"
#import "UserManager.h"



@class Draw;
@class Feed;
@class DrawFeed;
@class PBDraw;
@class PBDrawBg;
@class MyPaint;
@class PBUserStage;
@class PBUserTutorial;

@protocol  DrawDataServiceDelegate<NSObject>

@optional
- (void)didFindRecentDraw:(NSArray *)remoteDrawDataList result:(int)resultCode;
- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode;

- (void)didCreateDraw:(int)resultCode opusId:(NSString*)opusId;

- (void)didCreateLearnDraw:(int)resultCode
                    opusId:(NSString *)opusId
                 userStage:(PBUserStage*)userStage
              userTutorial:(PBUserTutorial*)userTutorial
;

- (void)didGuessOfflineDraw:(int)resultCode;

- (void)didSaveOpus:(BOOL)succ;
- (void)didSaveDraftOpus:(MyPaint*)draft;
@end


@interface DrawDataService : CommonService

+ (DrawDataService *)defaultService;

- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;

// return draw data
- (NSData*)createOfflineDraw:(NSArray*)drawActionList
                    image:(UIImage *)image
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language 
                targetUid:(NSString *)targetUid 
                contestId:(NSString *)contestId
                     desc:(NSString *)desc
                     size:(CGSize)size
                   layers:(NSArray *)layers
                    draft:(MyPaint *)draft
                   userStage:(PBUserStage*)userStage
                userTutorial:(PBUserTutorial*)userTutorial
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)matchDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;
- (void)matchOpus:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)guessDraw:(NSArray *)guessWords 
           opusId:(NSString *)opusId 
   opusCreatorUid:(NSString *)opusCreatorUid
        isCorrect:(BOOL)isCorrect 
            score:(NSInteger)score
         category:(PBOpusCategoryType)category
         delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;


- (PBDraw*)buildPBDraw:(NSString*)userId 
                  nick:(NSString *)nick
                avatar:(NSString *)avatar
        drawActionList:(NSArray*)drawActionList
              drawWord:(Word*)drawWord
              language:(LanguageType)language
                  size:(CGSize)size
          isCompressed:(BOOL)isCompressed;

- (void)savePaintWithPBDraw:(DrawFeed*)feed
                 pbDrawData:(NSData*)pbDrawData
                      image:(UIImage*)image
                   delegate:(id<DrawDataServiceDelegate>)delegate;


- (BOOL)savePaintWithPBDraw:(PBDraw*)pbDraw
             image:(UIImage*)image
          delegate:(id<DrawDataServiceDelegate>)delegate;

- (void)savePaintWithPBDraw:(DrawFeed*)feed
                 pbDrawData:(NSData*)pbDrawData
                      image:(UIImage*)image
                    isDraft:(BOOL)isDraft
                   delegate:(id<DrawDataServiceDelegate>)delegate;

- (BOOL)savePaintWithPBDrawData:(NSData*)pbDrawData
                          image:(UIImage*)image
                           word:(NSString*)word
                         opusId:(NSString*)opusId;

@end
