//
//  DrawColor.m
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawColor.h"
#import "Draw.pb.h"
#import "DrawUtils.h"
#import "Draw.pb-c.h"

@implementation DrawColor
@synthesize red = _red;
@synthesize green = _green;
@synthesize blue = _blue;
@synthesize alpha = _alpha;


- (void)dealloc
{
    [_color release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeFloat:_red forKey:@"red"];
    [aCoder encodeFloat:_green forKey:@"green"];
    [aCoder encodeFloat:_blue forKey:@"blue"];
    [aCoder encodeFloat:_alpha forKey:@"alpha"];
//    [aCoder encodeObject:_color forKey:@"color"];
    
}
- (void)setColor:(UIColor *)color
{
    if (_color != color) {
        if (_color) {
            PPRelease(_color);
        }
        _color = color;
        [_color retain];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _red = [aDecoder decodeFloatForKey:@"red"];
        _green = [aDecoder decodeFloatForKey:@"green"];
        _blue = [aDecoder decodeFloatForKey:@"blue"];
        _alpha = [aDecoder decodeFloatForKey:@"alpha"];
        self.color = [UIColor colorWithRed:_red green:_green blue:_blue alpha:_alpha];
//        _color = [aDecoder decodeObjectForKey:@"color"];
    }
    return self;
}

- (void)updateColor
{
    self.color = [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
}

#define CHANGE_VALUE_255(x) (x)//(((int)(x * 255)) / 255.0f)
//
- (void)setAlpha:(CGFloat)alpha
{
    if(_alpha != alpha){
        _alpha = alpha;
        _alpha = CHANGE_VALUE_255(_alpha);//((int)_alpha * 255) / 255.0f;
        [self updateColor];
    }
}

- (void)updateRGBA
{
    _red = CHANGE_VALUE_255(_red);//(int(_red * 255)) / 255.0f;
    _green = CHANGE_VALUE_255(_green);//(int(_green * 255)) / 255.0f;
    _blue = CHANGE_VALUE_255(_blue);//(int(_blue * 255)) / 255.0f;
    _alpha = CHANGE_VALUE_255(_alpha);//(int(_alpha * 255)) / 255.0f;
}

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self) {
        CGColorRef colorRef  = color.CGColor;
        const CGFloat* components = CGColorGetComponents( colorRef );
        size_t numComponents = CGColorGetNumberOfComponents( colorRef );
        
        CGFloat r, g, b, a;
        if( numComponents < 4 ) {
            PPDebug(@"invalide color. number of Components == %d", numComponents);
            return nil;
        }
        else {
            r = components[0];
            g = components[1];
            b = components[2];
            a = components[3];
            return [self initWithRed:r green:g blue:b alpha:a];
        }        
    }
    return self;
}

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    self = [super init];
    if (self) {
        _red = red;
        _green = green;
        _blue = blue;
        _alpha = alpha;
        [self updateRGBA];
        self.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return self;
}

- (id)initWithPBColor:(PBColor *)color
{
    self = [super init];
    if(self){
        _red = color.red;
        _green = color.green;
        _blue = color.blue;
        _alpha = color.alpha;
        [self updateRGBA];
        self.color = [UIColor colorWithRed:_red
                                     green:_green
                                      blue:_blue
                                     alpha:_alpha];
    }
    return self;
}

- (id)initWithPBColorC:(Game__PBColor *)color
{
    self = [super init];
    if(self){
        _red = color->red;
        _green = color->green;
        _blue = color->blue;
        _alpha = color->alpha;
        [self updateRGBA];
        self.color = [UIColor colorWithRed:_red
                                     green:_green
                                      blue:_blue
                                     alpha:_alpha];
    }
    return self;
}

- (PBColor *)toPBColor
{
    PBColorBuilder *builder = [[PBColorBuilder alloc] init];
    [builder setRed:self.red];
    [builder setGreen:self.green];
    [builder setBlue:self.blue];
    [builder setAlpha:self.alpha];
    PBColor *color = [builder build];
    [builder release];
    return color;
}

- (UIColor *)color
{
    return _color;
}

- (UIColor *)colorWithoutAlpha
{
    return [UIColor colorWithRed:_red green:_green blue:_blue alpha:1.0];
}

- (NSUInteger)hash
{
    NSInteger value = [DrawUtils compressDrawColor:self];
    return value;
}

- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object]) {
        return YES;
    }else
    {
        return [self hash] == [object hash];
    }
    return NO;
}
- (CGColorRef)CGColor
{
    return _color.CGColor;
}

- (NSString *)toString
{
   return [NSString stringWithFormat:@"DrawColor:[red = %f, green = %f, blue = %f ,alpha = %f]", self.red, self.green, self.blue, self.alpha];
}

- (NSString *)description
{
    return [self toString];
}

- (NSArray *)toRGBAComponent
{
    NSArray *array = [NSArray arrayWithObjects:@(self.red),@(self.green),@(self.blue),@(self.alpha), nil];
    return array;
}

+ (DrawColor *)colorWithRGBAComponent:(NSArray *)component
{
    if ([component count] >= 4) {
        CGFloat red = [[component objectAtIndex:0] floatValue];
        CGFloat green = [[component objectAtIndex:1] floatValue];
        CGFloat blue = [[component objectAtIndex:2] floatValue];
        CGFloat alpha = [[component objectAtIndex:3] floatValue];
        return [DrawColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
    return nil;
}


+ (DrawColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[[DrawColor alloc] initWithRed:red green:green blue:blue alpha:alpha]autorelease];
}

+ (DrawColor *)colorWithColor:(DrawColor *)color
{
    return [[[DrawColor alloc] initWithRed:color.red green:color.green blue:color.blue alpha:color.alpha] autorelease];
}

+ (DrawColor *)colorWithBetterCompressColor:(NSUInteger)color
{
//    DrawColor *drawColor = [[DrawColor alloc] init];
    CGFloat red, green, blue, alpha;
    [DrawUtils decompressColor8:color red:&red green:&green blue:&blue alpha:&alpha];
    return [DrawColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSUInteger)toBetterCompressColor
{
    return [DrawUtils compressDrawColor8:self];
}

+ (DrawColor *)blackColor      // 0.0 white 
{
    return [DrawColor colorWithRed:0 green:0 blue:0 alpha:1];
}

+ (DrawColor *)whiteColorWithAlpha:(CGFloat)alpha      // 1.0 white
{
    return [DrawColor colorWithRed:1 green:1 blue:1 alpha:alpha];
}

+ (DrawColor *)whiteColor      // 1.0 white 
{
    return [DrawColor colorWithRed:1 green:1 blue:1 alpha:1];
}
+ (DrawColor *)grayColor       // 0.5 white
{
    return [DrawColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
}
+ (DrawColor *)redColor        // 1.0, 0.0, 0.0 RGB
{
    return [DrawColor colorWithRed:1 green:0 blue:0 alpha:1];
}
+ (DrawColor *)greenColor      // 0.0, 1.0, 0.0 RGB 
{
    return [DrawColor colorWithRed:0 green:1 blue:0 alpha:1];
}
+ (DrawColor *)blueColor       // 0.0, 0.0, 1.0 RGB 
{
    return [DrawColor colorWithRed:0 green:0 blue:1 alpha:1];
}
+ (DrawColor *)cyanColor       // 0.0, 1.0, 1.0 RGB 
{
    return [DrawColor colorWithRed:0 green:1 blue:1 alpha:1];
}
+ (DrawColor *)yellowColor     // 1.0, 1.0, 0.0 RGB 
{
    return [DrawColor colorWithRed:1 green:1 blue:0 alpha:1];
}
+ (DrawColor *)magentaColor    // 1.0, 0.0, 1.0 RGB 
{
    return [DrawColor colorWithRed:1 green:0 blue:1 alpha:1];
}
+ (DrawColor *)pinkColor       // 1.0, 0.0, 1.0 RGB 
{
    return [DrawColor magentaColor];
}
+ (DrawColor *)skyColor       // 0.4, 0.87, 1.0 RGB
{
    return [DrawColor colorWithRed:0.4 green:0.87 blue:1.0 alpha:1];
}

+ (DrawColor *)orangeColor     // 1.0, 0.5, 0.0 RGB 
{
    return [DrawColor colorWithRed:1 green:0.5 blue:0 alpha:1];
}
+ (DrawColor *)purpleColor     // 0.5, 0.0, 0.5 RGB 
{
    return [DrawColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
}
+ (DrawColor *)brownColor      // 0.6, 0.4, 0.2 RGB 
{
    return [DrawColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1];
}
+ (DrawColor *)clearColor      // 0.0 white, 0.0 alpha 
{
    return [DrawColor colorWithRed:1 green:1 blue:1 alpha:0];
}

+ (DrawColor *)rankColor
{
    CGFloat R = (rand()%255)/255.0;
    CGFloat G = (rand()%255)/255.0;
    CGFloat B = (rand()%255)/255.0;    
    return [DrawColor colorWithRed:R green:G blue:B alpha:1];
}

+ (DrawColor *)midColorWithStartColor:(DrawColor *)startColor endColor:(DrawColor *)endColor
{
    CGFloat red =  (endColor.red + startColor.red) / 2;
    CGFloat green = (endColor.green + startColor.green) / 2;
    CGFloat blue = (endColor.blue + startColor.blue) / 2;
    CGFloat alpha = (endColor.alpha + startColor.alpha) / 2;
    DrawColor *midColor = [DrawColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return midColor;

}

@end
