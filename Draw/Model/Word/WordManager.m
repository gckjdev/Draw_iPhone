//
//  WordManager.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WordManager.h"
#import "Word.h"


#define WORD_DICT [[NSBundle mainBundle] pathForResource:@"WordDictionary" ofType:@"plist"]
#define WORD_BASE [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"]

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
        NSDictionary *pathDictionary = [NSDictionary dictionaryWithContentsOfFile:WORD_DICT];
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

- (NSString *)charWithKey:(NSString *)key dict:(NSDictionary *)dict outOfString:(NSString *)string
{
    
    
    
    NSArray *list = [dict objectForKey:key];
    int br = 0;
    while (list == nil && br < [string length]) {
        NSString *tempKey = [string substringWithRange:NSMakeRange(br, 1)];
        list = [dict objectForKey:tempKey];
        ++ br;
    }
    if (list) {
        for (int i = 0; i < [list count]; ++ i) {
            NSString *value = [list objectAtIndex:rand() % [list count]];            
            NSString *str1 = [value substringFromIndex:1];
            NSString *str2 = [value substringWithRange:NSMakeRange(0, 1)];
            NSInteger str1Loc = [string rangeOfString:str1].location;
            NSInteger str2Loc = [string rangeOfString:str2].location;
            if (str1Loc == NSNotFound) {
                return str1;
            }else if (str2Loc == NSNotFound) {
                return str2;
            }
        }    
    }
    return key;
}



- (NSString *)randLetterWithWord:(Word *)word count:(NSInteger)count
{
    if (word == nil) {
        return nil;
    }
    
    
    NSDictionary *wordBase = [NSDictionary dictionaryWithContentsOfFile:WORD_BASE];

    
    NSInteger length = word.text.length;
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    NSString *createSet = [NSString stringWithFormat:@"%@",word.text];
    for (int i = 0; i < count - length; ++ i) {
        NSInteger l = [createSet length];
        NSString *key = [createSet substringWithRange:NSMakeRange(rand() % l, 1)];
        NSString *value = [self charWithKey:key dict:wordBase outOfString:createSet];
        if ([createSet rangeOfString:value].location == NSNotFound) {
            createSet = [NSString stringWithFormat:@"%@%@",createSet,value];            
        }
        NSLog(@"createSet : %@", createSet);
        [retArray addObject:value];
    }
    
    for (int i = 0 ; i < length; ++ i) {
        NSString *value = [word.text substringWithRange:NSMakeRange(i, 1)];
        int k = rand() % retArray.count;
        [retArray insertObject:value atIndex:k];
    }
    return [retArray componentsJoinedByString:@""];

    
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
