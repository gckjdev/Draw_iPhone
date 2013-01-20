//
//  Word.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameConstants.pb.h"

typedef enum
{
    WordLevelUnknow = 0,
    WordLevelLow = 1,
    WordLeveLMedium = 2,
    WordLevelHigh = 3
}WordLevel;

@interface Word : NSObject<NSCoding>
{
    NSString *_wordId;
    PBWordType _wordType;
    WordLevel _level;
}

@property (copy, nonatomic) NSString *text;
@property (assign, nonatomic) int score;

// For Default
+ (Word *)wordWithText:(NSString *)text
                 level:(WordLevel)level;

+ (Word *)wordWithText:(NSString *)text
                 level:(WordLevel)level
                 score:(int)score;

// For system word
+ (Word *)sysWordWithText:(NSString *)text
                    level:(WordLevel)level;

// For my word
+ (Word *)cusWordWithText:(NSString *)text;

// For hot word
+ (Word *)hotWordWithId:(NSString *)wordId
                   text:(NSString *)text
                  score:(int)score;

- (NSString *)wordId;
- (PBWordType)wordType;
- (WordLevel)level;
- (NSInteger)score;

- (NSString *)levelDesc;
- (NSInteger)length;
- (NSData*)data;
+ (Word*)wordFromData:(NSData*)data;

@end

