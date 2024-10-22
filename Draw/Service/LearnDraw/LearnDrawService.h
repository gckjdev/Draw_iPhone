//
//  LearnDrawService.h
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "CommonService.h"
#import "SynthesizeSingleton.h"
#import "LearnDrawManager.h"



typedef void (^RequestArrayResultHandler)(NSArray* array, NSInteger resultCode);
typedef void (^RequestDictionaryResultHandler)(NSDictionary* dict, NSInteger resultCode);

@interface LearnDrawService : CommonService<SingletonProtocol>

//Admin methods
- (void)addOpusToLearnDrawPool:(NSString *)opusId
                         price:(NSInteger)price
                          type:(LearnDrawType)type
                 resultHandler:(RequestDictionaryResultHandler)handler;
- (void)removeLearnDraw:(NSString *)opusId
          resultHandler:(RequestDictionaryResultHandler)handler;


// Customer methods
- (void)buyLearnDraw:(NSString *)opusId
               price:(int)price
            fromView:(UIView *)fromView
       resultHandler:(RequestDictionaryResultHandler)handler;




- (void)getAllBoughtLearnDrawIdListWithResultHandler:(RequestArrayResultHandler)handler;

- (void)getBoughtLearnDrawOpusListWithOffset:(NSInteger)offset
                                       limit:(NSInteger)limit
                               ResultHandler:(RequestArrayResultHandler)handler;

- (void)getLearnDrawOpusListWithType:(LearnDrawType)type
                            sortType:(SortType)sortType
                              offset:(NSInteger)offset
                               limit:(NSInteger)limit
                       ResultHandler:(RequestArrayResultHandler)handler;

@end
