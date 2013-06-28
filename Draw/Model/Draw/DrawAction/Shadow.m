//
//  Shadow.m
//  Draw
//
//  Created by gamy on 13-6-27.
//
//

#import "Shadow.h"
#import "DrawColor.h"
#import "DrawUtils.h"


@interface Shadow()
{
    CGFloat _degree;
    CGFloat _distance;
}
@end

#define SHADOW(color, x, y, b) [Shadow shadowWithDrawColor:color offset:CGSizeMake(x, y) blur:b]


@implementation Shadow

- (void)dealloc
{
    PPRelease(_color);
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGSize:_offset forKey:@"offset"];
    [aCoder encodeFloat:_blur forKey:@"blur"];
    [aCoder encodeObject:_color forKey:@"color"];
}

- (void)updateDegreeAndDisdance
{
    CGFloat d = CGPointDistance(CGPointZero, CGPointMake(_offset.width, _offset.height));
    if (d != 0) {
        _degree = acosf(_offset.width / d) * 180 / M_PI;
    }
    _distance = d;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.offset = [aDecoder decodeCGSizeForKey:@"offset"];
        self.blur = [aDecoder decodeFloatForKey:@"blur"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        [self updateDegreeAndDisdance];
    }
    return self;
}

+ (Shadow *)shadowWithShadow:(Shadow *)shadow
{
    if (shadow) {
        return [Shadow shadowWithDrawColor:shadow.color offset:shadow.offset blur:shadow.blur];
    }
    return [Shadow shadowWithDrawColor:[DrawColor blackColor] offset:CGSizeZero blur:0];
}


+ (Shadow *)shadowWithIntColor:(NSUInteger)color offset:(CGSize)offset blur:(CGFloat)blur
{
    Shadow *shadow = [[Shadow alloc] init];
    [shadow setOffset:offset];
    shadow.color = [DrawColor colorWithBetterCompressColor:color];
    shadow.blur = blur;
    [shadow updateDegreeAndDisdance];
    return [shadow autorelease];
}

+ (Shadow *)shadowWithDrawColor:(DrawColor *)color offset:(CGSize)offset blur:(CGFloat)blur
{
    Shadow *shadow = [[Shadow alloc] init];
    [shadow setOffset:offset];
    shadow.color = [DrawColor colorWithColor:color];
    shadow.blur = blur;
    [shadow updateDegreeAndDisdance];
    return [shadow autorelease];
}

- (void)updateContext:(CGContextRef)context
{
    if (![self isEmpty]) {
        CGContextSetShadowWithColor(context, _offset, _blur, _color.CGColor);
    }
}

- (void)spanRect:(CGRect *)rect
{
    rect->origin.x -= ABS(self.offset.width);
    rect->origin.y -= ABS(self.offset.height);
    rect->size.width += 2 * ABS(self.offset.width);
    rect->size.height += 2 * ABS(self.offset.height);
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    pbDrawActionC->shadowoffsetx = self.offset.width;
    pbDrawActionC->has_shadowoffsetx = 1;
    
    pbDrawActionC->shadowoffsety = self.offset.height;
    pbDrawActionC->has_shadowoffsety = 1;
    
    if (self.color) {
        pbDrawActionC->has_shadowcolor = 1;
        pbDrawActionC->shadowcolor = [self.color toBetterCompressColor];
    }
    pbDrawActionC->shadowblur = self.blur;
    pbDrawActionC->has_shadowblur = 1;
    
}

- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    [builder setShadowOffsetX:self.offset.width];
    [builder setShadowOffsetY:self.offset.height];
    [builder setShadowBlur:self.blur];
    [builder setShadowColor:[self.color toBetterCompressColor]];
}

- (void)updateWithDegree:(CGFloat)degree distance:(CGFloat)distance
{
    _degree = degree;
    _distance = distance;
    
    CGFloat radio = degree / 180 * M_PI;
    _offset.width = cosf(radio)  * distance;
    _offset.height = sinf(radio) * distance;
}
- (CGFloat)distance
{
    return _distance;
}
- (CGFloat)degree
{
    return _degree;
}

- (NSUInteger)hash
{
    NSUInteger blur = _blur *100;
    NSUInteger x = _offset.width * 10000;
    NSUInteger y = _offset.height * 1000000;
    return blur + x + y + _color.hash;
}

- (BOOL)isEqual:(id)object
{
    Shadow *shadow = object;
    return self.blur == shadow.blur &&
    CGSizeEqualToSize(self.offset, shadow.offset) &&
    [self.color isEqual:shadow.color];
}

- (BOOL)isEmpty
{
    return _blur == 0 && CGSizeEqualToSize(CGSizeZero, _offset);
}

@end










////////////////////////////////////////////

ShadowManager *_staticShadowManager = nil;
@implementation ShadowManager


#define RECENT_SHADOWS @"RECENT_SHADOWS"
#define RECENT_SHADOW_COUNT 5

- (void)dealloc
{
    PPRelease(_recentShadowList);
    PPRelease(_systemShadowList);
    [super dealloc];
}


- (id)init
{
    self = [super init];
    if (self) {
        //Load recent data]
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:RECENT_SHADOWS];
        _recentShadowList = [[NSMutableArray arrayWithCapacity:RECENT_SHADOW_COUNT] retain];
        if (data) {
            NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([list count] > RECENT_SHADOW_COUNT) {
                list = [list subarrayWithRange:NSMakeRange(0, RECENT_SHADOW_COUNT)];
            }
            [_recentShadowList addObjectsFromArray:list];
        }
        
        //Load System data
        _systemShadowList = [[NSArray arrayWithObjects:
                              SHADOW([DrawColor blackColor], 2, 2, 1),
                              SHADOW([DrawColor greenColor], 6, 6, 2),
                              SHADOW([DrawColor blueColor], 2, -5, 3),
                              SHADOW([DrawColor orangeColor], -3, 2, 4),
                              nil] retain];
    }
    return self;
}

+ (id)defaultManager
{
    if (_staticShadowManager == nil) {
        _staticShadowManager = [[ShadowManager alloc] init];
    }
    return _staticShadowManager;
}
- (NSArray*)systemShadowList
{
    return _systemShadowList;
}
- (NSArray*)recentShadowList
{
    return _recentShadowList;
}
- (void)pushRecentShadow:(Shadow *)shadow
{
    if (shadow == nil) {
        return;
    }
    shadow = [Shadow shadowWithShadow:shadow];
    if (![_recentShadowList containsObject:shadow]) {
        [_recentShadowList insertObject:shadow atIndex:0];
        [self save];
    }
}
- (void)save
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_recentShadowList) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_recentShadowList];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:RECENT_SHADOWS];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    });
}


@end