//
//  WordManager.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserManager.h"
#import "DeviceDetection.h"

#define CN_WORD_COUNT_PER_PAGE 12
#define EN_WORD_COUNT_PER_PAGE (([DeviceDetection isIPAD]) ? 16 : 14)


#define KEY_LOW_LEVEL @"Low"
#define KEY_MEDIUM_LEVEL @"Medium"
#define KEY_HIGH_LEVEL @"High"
@class Word;


@interface WordManager : NSObject
{
    NSMutableDictionary *_wordDict;
    LanguageType _languageType;
    NSDictionary *wordBaseDictionary;
//    NSDictionary *wordDictionary;
}


@property(nonatomic,retain)NSMutableDictionary *wordDict;
@property(nonatomic, assign)LanguageType languageType;
+ (WordManager *)defaultManager;
- (void)addWord:(Word *)word; //when need to update the words, call the method
- (NSArray *)randDrawWordList; //will return a word list, and the list size is 3
- (NSString *)randChinesStringWithWord:(Word *)word count:(NSInteger)count;
- (NSString *)randEnglishStringWithWord:(Word *)word count:(NSInteger)count;
- (void)loadDictByWithLanguage:(LanguageType)languageType;
+ (NSString *)upperText:(NSString *)text;
+ (NSString *)bombCandidateString:(NSString *)candidateString word:(Word *)word;
+ (NSString *)changeToTraditionalChinese:(NSString *)text; 
+ (NSString *)removeSpaceFromString:(NSString *)string;
@end

extern WordManager *GlobalGetWordManager();
