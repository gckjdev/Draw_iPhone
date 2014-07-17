//
//  Billboard.m
//  Draw
//
//  Created by ChaoSo on 14-7-16.
//
//

#import "Billboard.h"

@implementation Billboard

+ (id) objectWithDictionary:(NSDictionary*)dictionary
{
    id obj = [[[Billboard alloc] initWithDictionary:dictionary] autorelease];
    return obj;
}

- (id) initWithDictionary:(NSDictionary*)dictionary
{
    self=[super init];
    if(self)
    {
        self.dataDict = dictionary;
    }
    return self;
}

- (int)index
{
    return [[_dataDict objectForKey:@"index"] intValue];
}

- (NSString*)image
{
    return [_dataDict objectForKey:@"image"];
}

- (NSString*)function
{
    return [_dataDict objectForKey:@"function"];
}

- (void)clickAction
{
    // TODO click action here
}

- (void)clickAction:(PPViewController*) pc{
    
    SEL selector = NSSelectorFromString(self.function);
    if (selector && [pc respondsToSelector:selector]){
        [pc performSelector:selector withObject:nil];
    }
    
}

- (void)dealloc{
    PPRelease(_dataDict);
    [super dealloc];
}

@end
