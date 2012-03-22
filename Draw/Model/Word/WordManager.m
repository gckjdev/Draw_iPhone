//
//  WordManager.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WordManager.h"
#import "Word.h"

WordManager *_wordManager;
WordManager *GlobalGetWordManager()
{
    if (_wordManager == nil) {
        _wordManager = [[WordManager alloc] init];
    }
    return _wordManager;
}

@implementation WordManager

+ (WordManager *)defaultManager
{
    return GlobalGetWordManager();
}




- (NSArray *)wordArrayOfLevel:(WordLevel)level
{
    switch (level) {
        case WordLevelLow:
            return [wordDict objectForKey:KEY_LOW_LEVEL];
        case WordLeveLMedium:
            return [wordDict objectForKey:KEY_MEDIUM_LEVEL];
        case WordLevelHigh:
            return [wordDict objectForKey:KEY_HIGH_LEVEL];
        default:
            return nil;
    }
}

- (NSMutableArray *)parsePathArray:(NSArray *)array
{
    NSMutableArray *retArray = [[[NSMutableArray alloc] init]autorelease];   
    for (NSArray *w in array) {
        NSString *text = [w objectAtIndex:0];
        NSNumber *level = [w objectAtIndex:1];
        Word *word = [[Word alloc] initWithText:text level:[level integerValue]];
        [retArray addObject:word];
        [word release];
    }
    return  retArray;

}


- (NSMutableDictionary *)parsePathDict:(NSDictionary *)pDict
{
    NSArray *lowArray = [pDict objectForKey:KEY_LOW_LEVEL];
    NSArray *mediumArray = [pDict objectForKey:KEY_MEDIUM_LEVEL];
    NSArray *highArray = [pDict objectForKey:KEY_HIGH_LEVEL];
    
    NSMutableArray *retLowArray = [self parsePathArray:lowArray];
    NSMutableArray *retMediumArray = [self parsePathArray:mediumArray];
    NSMutableArray *retHighArray = [self parsePathArray:highArray];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init]autorelease];
    [dict setObject:retLowArray forKey:KEY_LOW_LEVEL];
    [dict setObject:retMediumArray forKey:KEY_MEDIUM_LEVEL];
    [dict setObject:retHighArray forKey:KEY_HIGH_LEVEL];
    return dict;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        //load data
        NSString *path = [[NSBundle mainBundle] pathForResource:@"WordDictionary" ofType:@"plist"];
        NSDictionary *pathDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        wordDict = [self parsePathDict:pathDictionary];
        [wordDict retain];
    }
    
    return self;
}

- (void)dealloc
{
    [wordDict release];
    [super dealloc];
}

- (NSString *)randLetterWithWord:(Word *)word
{
    if (word == nil) {
        return nil;
    }
    NSString *str = @"北京天安门广场紫禁城乔丹詹姆斯足球篮球小鸡老鹰妖怪香蕉纸巾";
    NSInteger count = 16 - [word.text length];
    NSString *suffix = [str substringWithRange:NSMakeRange(0, count)];
    return [NSString stringWithFormat:@"%@%@",word.text,suffix];
//    NSInteger i = rand() % str.length;
//    return [str substringWithRange:NSMakeRange(i, 1)];
}

- (void)addWord:(Word *)word
{
    
}
- (NSArray *)randDrawWordList
{
    NSMutableArray *wordArray = [[[NSMutableArray alloc] initWithCapacity:3]autorelease];
    for (int i = WordLevelLow; i <= WordLevelHigh; ++i) {
        NSArray *array = [self wordArrayOfLevel:i];
        if ([array count] == 0) {
            return nil;
        }
        NSInteger index = rand() % [array count];
        Word *word = [array objectAtIndex:index];
        [wordArray addObject:word];
    }
    return wordArray;
}

@end
