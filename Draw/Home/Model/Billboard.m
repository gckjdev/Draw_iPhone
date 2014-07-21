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

-(NSArray *)paraList{
    return [_dataDict objectForKey:@"parameters"];
}
- (void)clickAction
{
    // TODO click action here
}

//Gallery 点击事件
- (void)clickAction:(PPViewController*) pc{
    
    NSArray* paraArray = [self paraList];
    
    int paraCount = [paraArray count];
    if (paraCount == 0){
        // no parameter
        SEL selector = NSSelectorFromString(self.function);
        if (selector && [pc respondsToSelector:selector]){
            [pc performSelector:selector withObject:nil];
        }
    }
    else if (paraCount == 1){
        // 1 parameter
        SEL selector = NSSelectorFromString(self.function);
        if (selector && [pc respondsToSelector:selector]){
            [pc performSelector:selector withObject:[paraArray objectAtIndex:0]];
        }
    }
    else if (paraCount >= 2){
        // 2 parameter
        SEL selector = NSSelectorFromString(self.function);
        if (selector && [pc respondsToSelector:selector]){
            [pc performSelector:selector
                     withObject:[paraArray objectAtIndex:0]
                     withObject:[paraArray objectAtIndex:1]];
        }
    }
    
    
}

- (void)dealloc{
    PPRelease(_dataDict);
    [super dealloc];
}

@end
