//
//  PhotoTagManager.h
//  Draw
//
//  Created by Kira on 13-6-14.
//
//

#import <Foundation/Foundation.h>

@interface PhotoTagManager : NSObject

+ (PhotoTagManager*)defaultManager;
- (NSArray*)tagPackageArray;
@end
