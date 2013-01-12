//
//  CustomWordManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

@interface CustomWordManager : NSObject

+ (CustomWordManager *)defaultManager;

- (BOOL)createCustomWordWithType:(NSNumber *)type 
                        word:(NSString *)word
                    language:(NSNumber *)language 
                       level:(NSNumber *)level;

- (BOOL)createCustomWord:(NSString *)word;

// return an array containing CustomWord objects.
- (NSArray *)findAllWords;

// return an array containing Word objects.
- (NSArray *)wordsFromCustomWords;

- (BOOL)deleteWord:(NSString *)word;

- (BOOL)update:(NSString *)oldWord newWord:(NSString *)newWord;

- (BOOL)isExist:(NSString *)word;

+ (BOOL)isValidWord:(NSString *)word;

@end
