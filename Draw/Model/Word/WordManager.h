//
//  WordManager.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define KEY_LOW_LEVEL @"Low"
#define KEY_MEDIUM_LEVEL @"Medium"
#define KEY_HIGH_LEVEL @"High"
@class Word;


@interface WordManager : NSObject
{
    NSMutableDictionary *wordDict;
}


+ (WordManager *)defaultManager;
- (NSInteger)scoreForWord:(Word *)word; //calculate the word score.
- (void)addWord:(Word *)word; //when need to update the words, call the method
- (NSArray *)randDrawWordList; //will return a word list, and the list size is 3


@end

extern WordManager *GlobalGetWordManager();
