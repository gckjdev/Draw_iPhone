//
//  WordFilterService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-15.
//
//

#import "WordFilterService.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"

#define FILTER_FILE_VERSION     @"1.0"

WordFilterService* globalDefaultWordFilterService;

@interface WordFilterService()
{
    PPSmartUpdateData* _smartData;
    NSArray* _forbiddenWordList;
}

@end

@implementation WordFilterService

+ (WordFilterService*)defaultService
{
    if (globalDefaultWordFilterService == nil){
        globalDefaultWordFilterService = [[WordFilterService alloc] init];
    }
    
    return globalDefaultWordFilterService;    
}

- (id)init
{
    self = [super init];
    
    _smartData = [[PPSmartUpdateData alloc] initWithName:@"filter"
                                                    type:SMART_UPDATE_DATA_TYPE_TXT
                                              bundlePath:@"filter.txt"
                                         initDataVersion:FILTER_FILE_VERSION];
    
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPRelease(_forbiddenWordList);
    } failureBlock:^(NSError *error) {
    }];
    
    return self;
}

- (void)dealloc
{
    PPRelease(_smartData);
    [super dealloc];
}

- (NSArray*)loadForbiddenWordList
{
    NSError* error = nil;
    NSString* allWords = [[NSString alloc] initWithContentsOfFile:_smartData.dataFilePath encoding:NSUTF8StringEncoding error:&error];
    NSArray* list = [allWords componentsSeparatedByString:@"\n"];
    [allWords release];
    return list;
}

- (NSArray*)forbiddenWordList
{
    if (_forbiddenWordList == nil){
        _forbiddenWordList = [[self loadForbiddenWordList] retain];
    }
    
    return _forbiddenWordList;
}

- (BOOL)containForbiddenWord:(NSString*)inputText
{
    if ([inputText length] == 0)
        return NO;
    
    if ([ConfigManager enableWordFilter] == NO)
        return NO;
    
    NSString* text = [inputText stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSArray* wordList = [self forbiddenWordList];
    for (NSString* word in wordList){
        if ([text rangeOfString:word].location != NSNotFound){
            PPDebug(@"<containForbiddenWord> word %@ forbidden!", word);
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)checkForbiddenWord:(NSString*)inputText
{
    BOOL result = [self containForbiddenWord:inputText];
    if (result){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kWordForbidden") delayTime:2.0f];
    }
    
    return result;
}

@end
