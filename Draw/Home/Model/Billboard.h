//
//  Billboard.h
//  Draw
//
//  Created by ChaoSo on 14-7-16.
//
//

#import <Foundation/Foundation.h>

@interface Billboard : NSObject

+ (id) objectWithDictionary:(NSDictionary*)dictionary;
- (id) initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, retain) NSDictionary* dataDict;

- (int)index;
- (NSString*)image;
- (NSString*)imageId;
- (NSString*)function;

- (void)clickAction:(PPViewController*) pc;

@end
