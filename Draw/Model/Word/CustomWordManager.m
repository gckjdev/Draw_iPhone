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

@interface CustomWordManager()
- (BOOL)isExist:(NSString *)word;
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

- (NSArray *)findAllWords
{
    CoreDataManager *dataManager = [CoreDataManager defaultManager];
    return [dataManager execute:@"findAllWords" sortBy:@"createDate" ascending:NO];
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

@end
