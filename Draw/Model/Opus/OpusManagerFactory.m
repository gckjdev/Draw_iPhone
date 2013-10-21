//
//  OpusManagerFactory.m
//  Draw
//
//  Created by 王 小涛 on 13-10-17.
//
//

#import "OpusManagerFactory.h"

@implementation OpusManagerFactory

+ (OpusManager *)createWithOpusClassName:(NSString *)name
                                  dbName:(NSString *)dbName{
    
    
    if ([name isEqualToString:OPUS_CLASS_NAME_SING]) {
        Class class = NSClassFromString(@"SingOpusManager");
        return [[[class alloc] initWihtDbName:dbName] autorelease];
    }else{
        return nil;
    }
}

@end
