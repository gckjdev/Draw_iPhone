//
//  HotWordManager.h
//  Draw
//
//  Created by 王 小涛 on 13-1-2.
//
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#import "Draw.pb.h"

@interface HotWordManager : NSObject

// return an array containing PBHotWord objects.
//@property (nonatomic, retain, readonly) NSArray *words;

+ (HotWordManager*)sharedHotWordManager;
+ (void)createTestData;

// return an array containing Word objects.
- (NSArray *)wordsFromPBHotWords;


@end
