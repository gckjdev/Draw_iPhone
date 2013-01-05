//
//  DrawColor.m
//  Draw
//
//  Created by  on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawColor.h"
#import "Draw.pb.h"

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
            [_color release];
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

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    [self updateColor];
}

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    self = [super init];
    if (self) {
        _red = red;
        _green = green;
        _blue = blue;
        _alpha = alpha;
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
        self.color = [UIColor colorWithRed:_red
                                     green:_green
                                      blue:_blue
                                     alpha:_alpha];
    }
    return self;
}

- (PBColor *)toPBColor
{
    PBColor_Builder *builder = [[PBColor_Builder alloc] init];
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

- (BOOL)isEqual:(id)object
{
    if ([super isEqual:object]) {
        return YES;
    }else
//    }else if([object isKindOfClass:[DrawColor class]])
    {
        DrawColor *other = (DrawColor *)object;
        if (other.red == self.red && other.green == self.green && other.blue == self.blue && other.alpha == self.alpha) {
            return YES;
        }
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

+ (DrawColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    return [[[DrawColor alloc] initWithRed:red green:green blue:blue alpha:alpha]autorelease];
}
+ (DrawColor *)blackColor      // 0.0 white 
{
    return [DrawColor colorWithRed:0 green:0 blue:0 alpha:1];
}


+ (DrawColor *)whiteColor      // 1.0 white 
{
    return [DrawColor colorWithRed:1 green:1 blue:1 alpha:1];
}
//+ (DrawColor *)grayColor;       // 0.5 white 
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


@end
