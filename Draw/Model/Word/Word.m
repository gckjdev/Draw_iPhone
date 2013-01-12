//
//  Word.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Word.h"
#import "LocaleUtils.h"
@implementation Word

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

- (id)initWithText:(NSString *)text
              type:(WordType)type
             level:(WordLevel)level
             score:(int)score
{
    self = [super init];
    if(self)
    {
        self.text = text;
        _wordType = type;
        _level = level;
        _score = score;
    }
    
    return self;
}

+ (Word *)wordWithText:(NSString *)text
                 level:(WordLevel)level
{
    return [[[Word alloc] initWithText:text type:WordTypeUnknow level:level score:[self scoreWithLevel:level]] autorelease];
}

// For system word
+ (Word *)sysWordWithText:(NSString *)text
                    level:(WordLevel)level
{
    
    return [[[Word alloc] initWithText:text type:WordTypeSystem level:level score:[self scoreWithLevel:level]] autorelease];
}

// For my word
+ (Word *)cusWordWithText:(NSString *)text
{
    return [[[Word alloc] initWithText:text type:WordTypeCustom level:WordLeveLMedium score:4] autorelease];
}

// For hot word
+ (Word *)hotWordWithText:(NSString *)text
                    score:(int)score
{
    return [[[Word alloc] initWithText:text type:WordTypeHot level:WordLeveLMedium score:score] autorelease];
}

- (WordType)wordType{
    return _wordType;
}

- (WordLevel)level{
    return _level;
}

- (NSInteger)score
{
    return _score;
}

- (NSString *)levelDesc
{
    switch (_level) {
        case WordLevelHigh:
            return NSLS(@"kHard");
        case WordLeveLMedium:
            return NSLS(@"kNormal");
        case WordLevelLow:
            return NSLS(@"kEasy");
        case WordLevelUnknow:
            return NSLS(@"");
        default:
            return NSLS(@"");
    }
}


- (NSInteger)length
{
    return _text.length;
}

+ (int)scoreWithLevel:(WordLevel)level{
    switch (level) {
        case WordLevelHigh:
            return 5;
            break;
            
        case WordLeveLMedium:
            return 4;
            break;
            
        case WordLevelLow:
            return 3;
            break;
            
        default:
            return 0;
            break;
    }
}


#define TEXT @"text"
#define LEVEL @"level"
#define WORDTYPE @"wordType"
#define SCORE @"score"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_text forKey:TEXT];
    [aCoder encodeInt:_level forKey:LEVEL];
    [aCoder encodeInt:_wordType forKey:WORDTYPE];
    [aCoder encodeInt: _score forKey:SCORE];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.text = [aDecoder decodeObjectForKey:TEXT];
        _level = [aDecoder decodeIntForKey:LEVEL];
        _wordType = [aDecoder decodeIntForKey:WORDTYPE];
        _score = [aDecoder decodeIntForKey:SCORE];
    }
    return self;
}


@end
