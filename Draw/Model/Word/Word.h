//
//  Word.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    WordLevelUnknow = 0,
    WordLevelLow = 1,
    WordLeveLMedium = 2,
    WordLevelHigh = 3
}WordLevel;


typedef enum
{
    WordTypeUnknow = 0,
    WordTypeSystem = 1,
    WordTypeCustom= 2,
    WordTypeHot = 3
}WordType;

@interface Word : NSObject<NSCoding>
{
    WordType _wordType;
    WordLevel _level;
    int _score;
}

@property (copy, nonatomic) NSString *text;

// For Default
+ (Word *)wordWithText:(NSString *)text
                 level:(WordLevel)level;

// For system word
+ (Word *)sysWordWithText:(NSString *)text
                    level:(WordLevel)level;

// For my word
+ (Word *)cusWordWithText:(NSString *)text;

// For hot word
+ (Word *)hotWordWithText:(NSString *)text
                    score:(int)score;

- (WordType)wordType;
- (WordLevel)level;
- (NSInteger)score;

- (NSString *)levelDesc;
- (NSInteger)length;

@end

