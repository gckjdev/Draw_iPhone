//
//  HotWordManager.m
//  Draw
//
//  Created by 王 小涛 on 13-1-2.
//
//

#import "HotWordManager.h"

#import "PPSmartUpdateData.h"
#import "PPSmartUpdateDataUtils.h"
#import "Word.h"
#import "ConfigManager.h"

#define HOT_WORD_FILE @"hot_word.pb"
#define BUNDLE_PATH @"hot_word.pb"
#define HOT_WORD_VERSION_KEY @"1.0"

@interface HotWordManager() {
}

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain, readwrite) NSArray *words;
@end

@implementation HotWordManager

SYNTHESIZE_SINGLETON_FOR_CLASS(HotWordManager)

- (void)dealloc
{
    [_smartData release];
    [_words release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        
        //load data
        [PPSmartUpdateDataUtils initPaths];
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:HOT_WORD_FILE type:SMART_UPDATE_DATA_TYPE_PB bundlePath:BUNDLE_PATH initDataVersion:HOT_WORD_VERSION_KEY] autorelease];
        
        [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    
    return self;
}

+ (void)createTestData
{
    PBHotWord_Builder *worder1 = [[[PBHotWord_Builder alloc] init] autorelease];
    [worder1 setWordId:@"1"];
    [worder1 setWord:@"电脑"];
    [worder1 setCoins:2];
    
    PBHotWord_Builder *worder2 = [[[PBHotWord_Builder alloc] init] autorelease];
    [worder2 setWordId:@"2"];
    [worder2 setWord:@"二逼青年快乐多"];
    [worder2 setCoins:3];
    
    PBHotWord_Builder *worder3 = [[[PBHotWord_Builder alloc] init] autorelease];
    [worder3 setWordId:@"3"];
    [worder3 setWord:@"苹果牌"];
    [worder3 setCoins:5];
    
    PBHotWordList_Builder *wordLister = [[[PBHotWordList_Builder alloc] init] autorelease];
    
    [wordLister addWords:[worder1 build]];
    [wordLister addWords:[worder2 build]];
    [wordLister addWords:[worder3 build]];
//    [wordLister addAllWords:[NSArray arrayWithObjects:[worder1 build], [worder2 build], [worder3 build], nil]];
 
    
    [[[wordLister build] data] writeToFile:@"/Users/Linruin/gitdata/Draw_iPhone/Draw/Draw/Resource/hot_word.pb" atomically:YES];
}

- (void)readData
{
    PPDebug(@"hot word file path : %@", _smartData.dataFilePath);
    @try {
        NSData *data = [NSData dataWithContentsOfFile:_smartData.dataFilePath];
        self.words = [[PBHotWordList parseFromData:data] wordsList];        
    }
    @catch (NSException *exception) {
        PPDebug(@"<readData>exception: %@",[exception description]);
    }
    @finally {
        
    }
}


- (NSArray *)wordsFromPBHotWords;
{
    [self readData];
    
    NSMutableArray *words = [NSMutableArray array];
    for (PBHotWord *hotWord in _words) {
        int coin = hotWord.coins;
        if (coin == 0){
            coin = [ConfigManager offlineDrawHotWordScore];
        }
        Word *word = [Word hotWordWithId:hotWord.wordId text:hotWord.word score:coin];
        [words addObject:word];
    }
    
    [words sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return (rand() % 2 == 0) ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    return words;
}

@end
