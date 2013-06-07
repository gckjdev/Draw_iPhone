//
//  TagPackage.h
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import <Foundation/Foundation.h>

@interface TagPackage : NSObject

@property (assign, nonatomic) int tagLimit;
@property (retain, nonatomic) NSArray* tagArray;
@property (assign, nonatomic) NSString* tagPackageName;

@end
