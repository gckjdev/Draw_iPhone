//
//  DrawPenProtocol.h
//  Draw
//
//  Created by gamy on 13-2-22.
//
//

#import <Foundation/Foundation.h>

@protocol DrawPenProtocol <NSObject>

@optional
- (UIImage *)penImage;
- (NSString *)name;
- (NSString *)desc;

@required
- (void)updateCGContext:(CGContextRef)context;

@end

