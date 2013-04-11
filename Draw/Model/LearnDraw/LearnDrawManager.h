//
//  LearnDrawManager.h
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

typedef enum {
    LearnDrawTypeAll = 0,
    
    LearnDrawTypeCartoon,
    LearnDrawTypeCharater,
    LearnDrawTypeScenery,
    
    LearnDrawTypeOther = 10000,
    
}LearnDrawType;

typedef enum {
    SortTypeTime = 1,
    SortTypeBoughtCount,    
}SortType;

@interface LearnDrawManager : NSObject<SingletonProtocol>

@property(nonatomic, retain)NSArray *boughtList;

- (void)updateBoughtList:(NSArray *)list;

@end
