//
//  Shadow.h
//  Draw
//
//  Created by gamy on 13-6-27.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb-c.h"

@class DrawColor;


@interface Shadow : NSObject<NSCoding>

@property(nonatomic, retain)DrawColor *color;
@property(nonatomic, assign)CGSize offset;
@property(nonatomic, assign)CGFloat blur;

+ (Shadow *)shadowWithShadow:(Shadow *)shadow;
+ (Shadow *)shadowWithIntColor:(NSUInteger)color offset:(CGSize)offset blur:(CGFloat)blur;
+ (Shadow *)shadowWithDrawColor:(DrawColor *)color offset:(CGSize)offset blur:(CGFloat)blur;
- (void)updateContext:(CGContextRef)context;
- (void)spanRect:(CGRect *)rect;
- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC;
- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder;

- (void)updateWithDegree:(CGFloat)degree distance:(CGFloat)distance;
- (CGFloat)distance;
- (CGFloat)degree;

- (BOOL)isEmpty;

@end




@interface ShadowManager : NSObject
{
    NSArray *_systemShadowList;
    NSMutableArray *_recentShadowList;
}
+ (id)defaultManager;
- (NSArray*)systemShadowList;
- (NSArray*)recentShadowList;
- (void)pushRecentShadow:(Shadow *)shadow;
- (void)save;

@end

