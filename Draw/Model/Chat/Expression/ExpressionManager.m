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
#define VALUE_PNG_SMILE @"face_smile.png"
#define VALUE_GIF_SMILE @"face_smile.gif"

#define KEY_PROUD @"[proud]"
#define VALUE_PNG_PROUD @"face_proud.png"
#define VALUE_GIF_PROUD @"face_proud.gif"

#define KEY_WRY @"[wry]"
#define VALUE_PNG_WRY @"face_wry.png"
#define VALUE_GIF_WRY @"face_wry.gif"

#define KEY_EMBARRASS @"[embarrass]"
#define VALUE_PNG_EMBARRASS @"face_embarrass.png"
#define VALUE_GIF_EMBARRASS @"face_embarrass.gif"

#define KEY_ANGER @"[anger]"
#define VALUE_PNG_ANGER @"face_anger.png"
#define VALUE_GIF_ANGER @"face_anger.gif"

#define KEY_HAPPY @"@happy@"
#define VALUE_PNG_HAPPY @"face_happy.png"
#define VALUE_GIF_HAPPY @"face_happy.gif"

#define KEY_CRY @"@cry@"
#define VALUE_PNG_CRY @"face_cry.png"
#define VALUE_GIF_CRY @"face_cry.gif"

#define KEY_RANDY @"@randy@"
#define VALUE_PNG_RANDY @"face_randy.png"
#define VALUE_GIF_RANDY @"face_randy.gif"

#define KEY_SHOCK @"@shock@"
#define VALUE_PNG_SHOCK @"face_shock.png"
#define VALUE_GIF_SHOCK @"face_shock.gif"

#define KEY_SHY @"@shy@"
#define VALUE_PNG_SHY @"face_shy.png"
#define VALUE_GIF_SHY @"face_shy.gif"

#define KEY_SLEEP @"@sleep@"
#define VALUE_PNG_SLEEP @"face_sleep.png"
#define VALUE_GIF_SLEEP @"face_sleep.gif"

#define KEY_CRAZY @"@crazy@"
#define VALUE_PNG_CRAZY @"face_crazy.png"
#define VALUE_GIF_CRAZY @"face_crazy.gif"

#define KEY_LOVELY @"@lovely@"
#define VALUE_PNG_LOVELY @"face_lovely.png"
#define VALUE_GIF_LOVELY @"face_lovely.gif"


static ExpressionManager *_instance = nil;

@interface ExpressionManager ()
{
    NSDictionary *_pngExpressionDictionary;
    NSArray *_pngKeys;
    NSArray *_pngValues;
    
    NSDictionary *_gifExpressionDictionary;
    NSArray *_gifKeys;
    NSArray *_gifValues;
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
        _pngKeys = [[NSArray arrayWithObjects:
                     KEY_SMILE,
                     KEY_HAPPY,
                     KEY_CRY,
                     KEY_EMBARRASS,
                     KEY_ANGER,
                     
                     KEY_RANDY,
                     KEY_SHOCK,
                     KEY_SHY,
                     KEY_SLEEP,
                     KEY_CRAZY,
                     
                     KEY_PROUD,
                     KEY_LOVELY,
                     KEY_WRY,
                     nil] retain];
        
        _pngValues = [[NSArray arrayWithObjects:
                       VALUE_PNG_SMILE,
                       VALUE_PNG_HAPPY,
                       VALUE_PNG_CRY,
                       VALUE_PNG_EMBARRASS,
                       VALUE_PNG_ANGER,
                       
                       VALUE_PNG_RANDY,
                       VALUE_PNG_SHOCK,
                       VALUE_PNG_SHY,
                       VALUE_PNG_SLEEP,
                       VALUE_PNG_CRAZY,
                       
                       VALUE_PNG_PROUD,
                       VALUE_PNG_LOVELY,
                       VALUE_PNG_WRY,
                       nil] retain];
        
        _pngExpressionDictionary = [[NSDictionary dictionaryWithObjects:_pngValues forKeys:_pngKeys] retain];
        
        _gifKeys = [[NSArray arrayWithObjects:
                     KEY_SMILE,
                     KEY_HAPPY,
                     KEY_CRY, 
                     KEY_EMBARRASS,
                     KEY_ANGER,

                     KEY_RANDY, 
                     KEY_SHOCK, 
                     KEY_SHY, 
                     KEY_SLEEP,
                     KEY_CRAZY, 

                     KEY_PROUD,
                     KEY_LOVELY, 
                     KEY_WRY, 
                     
                     nil] retain];
        _gifValues = [[NSArray arrayWithObjects:
                       VALUE_GIF_SMILE, 
                       VALUE_GIF_HAPPY,
                       VALUE_GIF_CRY,
                       VALUE_GIF_EMBARRASS, 
                       VALUE_GIF_ANGER, 

                       VALUE_GIF_RANDY,
                       VALUE_GIF_SHOCK,
                       VALUE_GIF_SHY,
                       VALUE_GIF_SLEEP, 
                       VALUE_GIF_CRAZY,

                       VALUE_GIF_PROUD,
                       VALUE_GIF_LOVELY,
                       VALUE_GIF_WRY, 
                       
                       nil] retain];
        _gifExpressionDictionary = [[NSDictionary dictionaryWithObjects:_gifValues forKeys:_gifKeys] retain];
    }
    
    return self;
}

- (void)dealloc
{
    [_pngExpressionDictionary release]; 
    [_pngKeys release];
    [_pngValues release];
    [_gifExpressionDictionary release];
    [_gifKeys release];
    [_gifValues release];
    [super dealloc];
}


- (NSArray *)allPngKeys
{
    return _pngKeys;
}

- (NSArray *)allGifKeys
{
    return _gifKeys;
}

- (UIImage *)pngExpressionForKey:(NSString*)key
{
    NSString *value = [_pngExpressionDictionary objectForKey:key];
    PPDebug(@"value = %@", value);
    UIImage *image = [UIImage imageNamed:value];
    return image;
}

- (GifView *)gifExpressionForKey:(NSString *)key frame:(CGRect)frame
{
    NSString *gifFile = [_gifExpressionDictionary objectForKey:key];
    NSArray *array = [gifFile componentsSeparatedByString:@"."];
    if ([array count] < 2) {
        return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:0] 
                                                     ofType:[array objectAtIndex:1]];
    
    if (path == nil) {
        return nil;
    }
    
    GifView* view = [[[GifView alloc] initWithFrame:frame
                                           filePath:path
                                   playTimeInterval:0.2] autorelease];
    
    return view;
}



@end
