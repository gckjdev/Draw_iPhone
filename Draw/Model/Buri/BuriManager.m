//
//  BuriManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "BuriManager.h"
#import "BuriSerialization.h"
#import "Buri.h"

#import "SynthesizeSingleton.h"


@interface BuriManager()

@end

@implementation BuriManager

SYNTHESIZE_SINGLETON_FOR_CLASS(BuriManager);

- (void)dealloc{
    
    [_db release];
    [super dealloc];
}

- (id)init{
    
    if (self = [super init]) {
        self.db = [Buri databaseInLibraryWithName:@"database.buri"];
    }
        
    return self;
}

- (BuriBucket *)createBucketWithObjectClass:(Class)class{
    
    BuriBucket *bucket = [[[BuriBucket alloc] initWithDB:_db andObjectClass:class] autorelease];
    return bucket;
}


@end
