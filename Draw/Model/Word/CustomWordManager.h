//
//  CustomWordManager.h
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{ 
    WordTypeCustom = 1,
    WordTypeSystem = 2,
}WordType;

@interface CustomWordManager : NSObject

+ (CustomWordManager *)defaultManager;

- (BOOL)createCustomWordWithType:(NSNumber *)type 
                        word:(NSString *)word
                    language:(NSNumber *)language 
                       level:(NSNumber *)level;

- (NSArray *)findAllWords;

@end
