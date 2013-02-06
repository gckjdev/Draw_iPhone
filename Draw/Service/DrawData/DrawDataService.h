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

@protocol  DrawDataServiceDelegate<NSObject>

@optional
- (void)didFindRecentDraw:(NSArray *)remoteDrawDataList result:(int)resultCode;
- (void)didMatchDraw:(DrawFeed *)feed result:(int)resultCode;

- (void)didCreateDraw:(int)resultCode;
- (void)didGuessOfflineDraw:(int)resultCode;

- (void)didSaveOpus:(BOOL)succ;
@end


@interface DrawDataService : CommonService

+ (DrawDataService *)defaultService;

- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)createOfflineDraw:(NSArray*)drawActionList
                    image:(UIImage *)image
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language 
                targetUid:(NSString *)targetUid 
                contestId:(NSString *)contestId
                     desc:(NSString *)desc
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)matchDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)guessDraw:(NSArray *)guessWords 
           opusId:(NSString *)opusId 
   opusCreatorUid:(NSString *)opusCreatorUid
        isCorrect:(BOOL)isCorrect 
            score:(NSInteger)score
         delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (PBDrawAction *)buildPBDrawAction:(DrawAction *)drawAction;

- (PBDraw*)buildPBDraw:(NSString*)userId 
                  nick:(NSString *)nick 
                avatar:(NSString *)avatar
        drawActionList:(NSArray*)drawActionList
              drawWord:(Word*)drawWord
              language:(LanguageType)language;

// save draw data locally
//- (void)saveActionList:(NSArray *)actionList 
//                userId:(NSString*)userId 
//              nickName:(NSString*)nickName 
//             isMyPaint:(BOOL)isMyPaint
//                  word:(NSString*)word
//                 image:(UIImage*)image
//        delegate:(id<DrawDataServiceDelegate>)delegate;

- (void)savePaintWithPBDraw:(PBDraw*)pbDraw
             image:(UIImage*)image
          delegate:(id<DrawDataServiceDelegate>)delegate;

//                userId:(NSString*)userId
//              nickName:(NSString*)nickName
//             isMyPaint:(BOOL)isMyPaint
//                  word:(NSString*)word



@end
