//
//  TagPackage.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import <Foundation/Foundation.h>

@interface TagPackage : NSObject

@property (retain, nonatomic, readonly) NSMutableArray* tagArray;
@property (retain, nonatomic, readonly) NSString* tagPackageName;

- (id)initWithString:(NSString*)str;
+ (NSArray*)createPackageArrayFromString:(NSString*)str;

@end
