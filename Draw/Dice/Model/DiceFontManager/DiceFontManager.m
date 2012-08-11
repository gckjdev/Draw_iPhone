//
//  DiceFontManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceFontManager.h"
#import "FontManager.h"
#import "DeviceDetection.h"

#define HKGIRL_FONT @"diceFont"

static DiceFontManager *_defaultManager = nil;

@interface DiceFontManager()

@property (retain, nonatomic) NSString *fontName;

@end

@implementation DiceFontManager

@synthesize fontName = _fontName;

- (void)dealloc
{
    [_fontName release];
    [super dealloc];
}

+ (DiceFontManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceFontManager alloc] init];
    }

    return _defaultManager;
}

- (id)init
{
    if (self = [super init]) {
        if ([DeviceDetection isOS5]) {
            self.fontName = HKGIRL_FONT;
            [[FontManager sharedManager] loadFont:_fontName];
        }else {
            self.fontName = @"Arial";
        }
    }
    
    return self;
}

- (NSString *)fontName
{
    return _fontName;
}

@end
