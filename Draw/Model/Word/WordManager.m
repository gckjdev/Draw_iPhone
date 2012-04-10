//
//  WordManager.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WordManager.h"
#import "Word.h"

#define CN_WORD_DICT [[NSBundle mainBundle] pathForResource:@"CN_Words_Dict" ofType:@"plist"]
#define EN_WORD_DICT [[NSBundle mainBundle] pathForResource:@"EN_Words_Dict" ofType:@"plist"]

#define WORD_BASE [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"]

NSString *UPPER_LETTER_LIST[] = {@"A", @"B", @"C", @"D", @"E", 
    @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", 
    @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"};

NSString *LOWER_LETTER_LIST[] = {@"a", @"b", @"c", @"d", @"e", 
    @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", 
    @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"};

WordManager *_wordManager;
WordManager *GlobalGetWordManager()
{
    if (_wordManager == nil) {
        _wordManager = [[WordManager alloc] init];
    }
    return _wordManager;
}

@implementation WordManager
@synthesize wordDict = _wordDict;
@synthesize languageType = _languageType;

+ (WordManager *)defaultManager
{
    WordManager *manager = GlobalGetWordManager();
    [manager loadDictByWithLanguage:[[UserManager defaultManager] getLanguageType]];
    return manager;
}

- (NSArray *)wordArrayOfLevel:(WordLevel)level
{
    switch (level) {
        case WordLevelLow:
            return [_wordDict objectForKey:KEY_LOW_LEVEL];
        case WordLeveLMedium:
            return [_wordDict objectForKey:KEY_MEDIUM_LEVEL];
        case WordLevelHigh:
            return [_wordDict objectForKey:KEY_HIGH_LEVEL];
        default:
            return nil;
    }
}

- (NSMutableArray *)parsePathArray:(NSArray *)array level:(WordLevel)level
{
    NSMutableArray *retArray = [[[NSMutableArray alloc] init]autorelease];   
    for (NSString *text in array) {
        Word *word = [[Word alloc] initWithText:text level:level];
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
    
    NSMutableArray *retLowArray = [self parsePathArray:lowArray level:WordLevelLow];
    NSMutableArray *retMediumArray = [self parsePathArray:mediumArray level:WordLeveLMedium];
    NSMutableArray *retHighArray = [self parsePathArray:highArray level:WordLevelHigh];
    
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init]autorelease];
    [dict setObject:retLowArray forKey:KEY_LOW_LEVEL];
    [dict setObject:retMediumArray forKey:KEY_MEDIUM_LEVEL];
    [dict setObject:retHighArray forKey:KEY_HIGH_LEVEL];
    return dict;
    
}

- (void)loadDictByWithLanguage:(LanguageType)languageType
{
    if (languageType == _languageType && self.wordDict != nil) {
        return;
    }else{
        NSDictionary *pathDictionary = nil;
        if (languageType == ChineseType) {
            pathDictionary = [NSDictionary dictionaryWithContentsOfFile:CN_WORD_DICT];            
        }else {
            pathDictionary = [NSDictionary dictionaryWithContentsOfFile:EN_WORD_DICT];            
        }
        self.wordDict = [self parsePathDict:pathDictionary];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        //load data
    }
    return self;
}

- (void)dealloc
{
    [_wordDict release];
    [super dealloc];
}

- (NSString *)charWithKey:(NSString *)key dict:(NSDictionary *)dict outOfString:(NSString *)string
{
    
    NSArray *list = [dict objectForKey:key];
    int br = 0;
    
    // find the word list with the letter in string
    while (list == nil && br < [string length]) {
        NSString *tempKey = [string substringWithRange:NSMakeRange(br, 1)];
        list = [dict objectForKey:tempKey];
        ++ br;
    }
    
    if (list) {
        for (int i = 0; i < [list count]; ++ i) {
            //find the letter in the list but not in the string.
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
    
    //if can find the unique letter, then rand a word.
    NSInteger index = rand() % 3 + 1;
    NSArray *wordArray = [self wordArrayOfLevel:index];
    index = rand() %[wordArray count];
    Word *word = [wordArray objectAtIndex:index];
    NSString *str = [word.text substringToIndex:1];
    return str;
}



- (NSString *)randChinesStringWithWord:(Word *)word count:(NSInteger)count
{
    if (word == nil || [word.text length] == 0) {
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

- (NSString *)randEnglishStringWithWord:(Word *)word count:(NSInteger)count
{
    if (word == nil || [word.text length] == 0) {
        return nil;
    }
    NSInteger length = word.text.length;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count - length; ++i) {
        NSInteger index = rand() % 26;
        NSString *letter = UPPER_LETTER_LIST[index];
        [array addObject:letter];
    }
    for (int i = 0; i < length; ++ i) {
        NSInteger index = rand() % [array count];
        NSString *string = [word.text substringWithRange:NSMakeRange(i, 1)];
        [array insertObject:string atIndex:index];
    }
    return [array componentsJoinedByString:@""];
}


+ (NSString *)bombCandidateString:(NSString *)candidateString word:(Word *)word
{
    NSString *text = word.text;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [text length]; ++ i) {
        NSString *charString = [text substringWithRange:NSMakeRange(i, 1)];
        NSNumber *count = [dict objectForKey:charString];
        if (count) {
            count = [NSNumber numberWithInt:(count.integerValue + 1)];
        }else{
            count = [NSNumber numberWithInt:1];
        }
        [dict setObject:count forKey:charString];
    }
    const int CANDIDATE_LENGTH = 50;
    BOOL canDeleteIndex[CANDIDATE_LENGTH] = {NO};
    for (int i = 0; i < candidateString.length; ++ i) {
        NSString *subString = [candidateString substringWithRange:NSMakeRange(i, 1)];
        NSNumber *number = [dict objectForKey:subString];
        if (number == nil || number.integerValue == 0) {
            canDeleteIndex[i] = YES;
        }else{
            canDeleteIndex[i] = NO;
            NSInteger count = number.integerValue - 1;
            number = [NSNumber numberWithInt:count];
            [dict setObject:number forKey:subString];
        }
    }
    [dict release];
    
    NSInteger count = MIN(candidateString.length/2, candidateString.length - text.length);
    NSMutableString *s = [NSMutableString stringWithString:candidateString];

    NSInteger index = rand() % s.length;
    while (count) {
        unichar ch = [s characterAtIndex:index];
        if (ch != ' ' && canDeleteIndex[index]) {
            count --;
            ch = ' ';
            NSString *rep = [NSString stringWithFormat:@"%c",ch];
            [s replaceCharactersInRange:NSMakeRange(index, 1) withString:rep];
            index = rand() % s.length;
        }else{
            index = (index + 1) % s.length;
        }
    }

    return s;
}
+ (NSString *)upperText:(NSString *)text
{
    if (text == nil) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithString:text];
    for (int i = 0; i < string.length; ++ i) {
        unichar ch = [string characterAtIndex:i];
        if (ch >= 'a' && ch <= 'z') {
            ch = ch + ('A' - 'a');
            NSString *str = [NSString stringWithFormat:@"%c",ch];
            [string replaceCharactersInRange:NSMakeRange(i, 1) withString:str];
        }
    }
    return string;
}

@end
