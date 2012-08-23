//
//  ExpressionManager.m
//  Draw
//
//  Created by 小涛 王 on 12-5-9.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ExpressionManager.h"
#import "PPDebug.h"

#define KEY_SMILE @"[smile]"
#define VALUE_SMILE @"face_smile.png"
#define KEY_PROUD @"[proud]"
#define VALUE_PROUD @"face_proud.png"
#define KEY_EMBARRASS @"[embarrass]"
#define VALUE_EMBARRASS @"face_embarrass.png"
#define KEY_WRY @"[wry]"
#define VALUE_WRY @"face_wry.png"
#define KEY_ANGER @"[anger]"
#define VALUE_ANGER @"face_anger.png"

static ExpressionManager *_instance = nil;

@interface ExpressionManager ()
{
    NSDictionary *_expressionDictionary;
}
@end

@implementation ExpressionManager

+ (ExpressionManager *)defaultManager
{
    if (_instance == nil) {
        _instance = [[ExpressionManager alloc] init];
    }
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *keys = [NSArray arrayWithObjects:KEY_SMILE, KEY_PROUD, KEY_EMBARRASS, KEY_WRY, KEY_ANGER, nil];
        NSArray *values = [NSArray arrayWithObjects:VALUE_SMILE, VALUE_PROUD, VALUE_EMBARRASS, VALUE_WRY, VALUE_ANGER, nil];

        _expressionDictionary = [[NSDictionary dictionaryWithObjects:values forKeys:keys] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_expressionDictionary release]; 
    [super dealloc];
}

- (UIImage *)expressionForKey:(NSString*)key
{
    NSString *value = [_expressionDictionary valueForKey:key];
    PPDebug(@"value = %@", value);
    UIImage *image = [UIImage imageNamed:value];
    return image;
}

- (NSArray *)allKeys
{
    return [_expressionDictionary allKeys];
}


- (NSString *)gifPathForExpression:(NSString *)key
{
    NSString *value = [_expressionDictionary valueForKey:key];
    NSArray *subStr = [value componentsSeparatedByString:@"."];
    return [[NSBundle mainBundle] pathForResource:[subStr objectAtIndex:0] ofType:@"gif"];
}
//- (NSArray *)allValues
//{
//    return [_expressionDictionary allValues];
//}


@end
