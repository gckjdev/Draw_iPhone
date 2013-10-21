//
//  OpusManagerFactory.h
//  Draw
//
//  Created by 王 小涛 on 13-10-17.
//
//

#import "OpusManager.h"

#define OPUS_CLASS_NAME_SING @"SingOpus"

@interface OpusManagerFactory : NSObject

+ (OpusManager *)createWithOpusClassName:(NSString *)name
                                  dbName:(NSString *)dbName;

@end
