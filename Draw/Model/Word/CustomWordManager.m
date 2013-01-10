//
//  CustomWordManager.m
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "CustomWordManager.h"
#import "CoreDataUtil.h"
#import "CustomWord.h"
#import "UserManager.h"
#import "CommonMessageCenter.h"
#import "StringUtil.h"

@interface CustomWordManager()

@end


@implementation CustomWordManager

static CustomWordManager *_customWordManager = nil;

+ (CustomWordManager *)defaultManager
{
    if (_customWordManager == nil) {
        _customWordManager = [[CustomWordManager alloc] init];
    }
    return _customWordManager;
}

- (BOOL)createCustomWordWithType:(NSNumber *)type 
                            word:(NSString *)word
                        language:(NSNumber *)language 
                           level:(NSNumber *)level
{
    if ([self isExist:word]) {
        return YES;
    }
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    CustomWord *newCustomWord = [dataManager insert:@"CustomWord"];
    [newCustomWord setType:type];
    [newCustomWord setWord:word];
    [newCustomWord setLanguage:language];
    [newCustomWord setCreateDate:[NSDate date]];
    [newCustomWord setLastUseDate:[NSDate date]];
    [newCustomWord setLevel:level];
    return [dataManager save];
}

- (BOOL)createCustomWord:(NSString *)word
{
    if ([self isExist:word]) {
        return YES;
    }
    
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    CustomWord *newCustomWord = [dataManager insert:@"CustomWord"];
    [newCustomWord setType:[NSNumber numberWithInt:WordTypeCustom]];
    [newCustomWord setWord:word];
    [newCustomWord setLanguage:[NSNumber numberWithInt:ChineseType]];
    [newCustomWord setCreateDate:[NSDate date]];
    [newCustomWord setLastUseDate:[NSDate date]];
    [newCustomWord setLevel:[NSNumber numberWithInt:WordLeveLMedium]];
    return [dataManager save];
}

- (NSArray *)findAllWords
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllWords" sortBy:@"createDate" ascending:NO];
}

- (NSArray *)wordsFromCustomWords
{
    NSMutableArray *words = [NSMutableArray array];
    for (CustomWord *cusWord in [self findAllWords]) {
        Word *word = [Word wordWithText:cusWord.word level:WordLeveLMedium];
        [words addObject:word];
    }
    
    return words;
}

- (BOOL)isExist:(NSString *)word
{
    NSArray *array = [self findAllWords];
    for (CustomWord *customWord in array) {
        if ([customWord.word isEqualToString:word]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)deleteWord:(NSString *)word
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *array = [self findAllWords];
    for (CustomWord *customWord in array) {
        if ([customWord.word isEqualToString:word]) {
            [dataManager del:customWord];
            break;
        }
    }
    return [dataManager save];
}

- (BOOL)update:(NSString *)oldWord newWord:(NSString *)newWord
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    NSArray *array = [self findAllWords];
    for (CustomWord *customWord in array) {
        if ([customWord.word isEqualToString:oldWord]) {
            [customWord setWord:newWord];
        }
    }
    return [dataManager save];
}


+ (BOOL)isValidWord:(NSString *)word
{
    if ([word length] == 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kInputWordEmpty"),word] delayTime:2 isHappy:NO];
        return NO;
    }
    
    if ([word length] > 7) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kWordTooLong"),word] delayTime:2 isHappy:NO];
        return NO;
    }
    
    if (!NSStringIsValidChinese(word)){
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kIllegalCharacter"),word] delayTime:2 isHappy:NO];
        return NO;
    }
    
    if ([[self defaultManager] isExist:word]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kExistWord"),word] delayTime:2 isHappy:NO];
        return NO;
    }
    
    return YES;
}

@end
