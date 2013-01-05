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
@synthesize level = _level;
@synthesize text = _text;

- (id)initWithText:(NSString *)text level:(WordLevel)level
{
    self = [super init];
    if(self)
    {
        self.text = text;
        self.level = level;
    }
    return self;
}

- (id)initWithText:(NSString *)text level:(WordLevel)level score:(int)score
{
    self = [super init];
    if(self)
    {
        self.text = text;
        self.level = level;
        _score = score;
    }
    
    return self;
}

+ (Word *)wordWithText:(NSString *)text level:(WordLevel)level
{
    return [[[Word alloc] initWithText:text level:level] autorelease];
}

+ (Word *)wordWithText:(NSString *)text level:(WordLevel)level score:(int)score
{
    return [[[Word alloc] initWithText:text level:level score:score] autorelease];
}

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

- (NSInteger)score
{
    if (_score != 0) {
        return _score;
    }
    
    switch (self.level) {
        case WordLevelHigh:
            return 5;
        case WordLeveLMedium:
            return 4;
        case WordLevelLow:
        default:
            return 3;
    }
}

- (NSString *)levelDesc
{
    switch (self.level) {
        case WordLevelHigh:
            return NSLS(@"kHard");
        case WordLeveLMedium:
            return NSLS(@"kNormal");
        case WordLevelLow:
        default:
            return NSLS(@"kEasy");
    }
}


- (NSInteger)length
{
    return self.text.length;
}

#define TEXT @"text"
#define LEVEL @"level"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_text forKey:TEXT];
    [aCoder encodeInt:_level forKey:LEVEL];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.text = [aDecoder decodeObjectForKey:TEXT];
        self.level = [aDecoder decodeIntForKey:LEVEL];
    }
    return self;
}


@end
