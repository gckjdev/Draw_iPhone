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
@protocol  DrawDataServiceDelegate<NSObject>

@optional
- (void)didFindRecentDraw:(NSArray *)remoteDrawDataList result:(int)resultCode;
- (void)didFindRecentDraw:(NSArray *)remoteDrawDataList result:(int)resultCode;
- (void)didMatchDraw:(Feed *)feed result:(int)resultCode;

- (void)didCreateDraw:(int)resultCode;
- (void)didGuessOfflineDraw:(int)resultCode;

@end


@interface DrawDataService : CommonService

+ (DrawDataService *)defaultService;

- (void)findRecentDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)createOfflineDraw:(NSArray*)drawActionList
                 drawWord:(Word*)drawWord
                 language:(LanguageType)language
                 delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)matchDraw:(PPViewController<DrawDataServiceDelegate>*)viewController;

- (void)guessDraw:(NSArray *)guessWords 
           opusId:(NSString *)opusId
        isCorrect:(BOOL)isCorrect 
            score:(NSInteger)score
         delegate:(PPViewController<DrawDataServiceDelegate>*)viewController;
@end
