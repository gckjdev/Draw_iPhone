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

- (void)dealloc
{
    [_text release];
    [super dealloc];
}

- (NSInteger)score
{
    switch (self.level) {
        case WordLevelHigh:
            return 3;
        case WordLeveLMedium:
            return 2;
        case WordLevelLow:
        default:
            return 1;
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
+ (Word *)wordWithText:(NSString *)text level:(WordLevel)level
{
    return [[[Word alloc] initWithText:text level:level]autorelease];
}
@end
