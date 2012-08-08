//
//  DrawFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"


typedef enum{
    ActionTypeHidden = 0,
    ActionTypeOneMore = 1,
    ActionTypeGuess = 2,
    ActionTypeCorrect = 3,
    ActionTypeChallenge = 4
}ActionType;


@interface DrawFeed : Feed
{
    Draw *_drawData;
    UIImage *_drawImage;
    NSString *_wordText;
    NSString *_drawImageUrl;
    NSSet *_timesSet;

}

@property (nonatomic, retain) UIImage *drawImage;;
@property (nonatomic, retain) NSString *wordText;
@property (nonatomic, retain) Draw *drawData;
@property (nonatomic, retain) NSString *drawImageUrl;
@property (nonatomic, retain) NSSet *timesSet;

- (id)initWithPBFeed:(PBFeed *)pbFeed;
- (id)initWithFeedId:(NSString *)feedId
              userId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender 
        drawImageUrl:(NSString *)drawImageUrl 
              pbDraw:(PBDraw *)pbDraw 
            wordText:(NSString *)wordText 
          timesArray:(NSArray *)timesArray;

- (void)parseDrawData:(PBFeed *)pbFeed;
- (BOOL)isMyOpus;
- (BOOL) hasGuessed;
- (void)incGuessTimes;
- (void)incCorrectTimes;
- (NSInteger)guessTimes;
- (NSInteger)matchTimes;
- (NSInteger)saveTimes;
- (NSInteger)correctTimes;
- (NSInteger)flowerTimes;
- (NSInteger)tomatoTimes;
- (ActionType)actionType;
@end
