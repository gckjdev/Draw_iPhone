//
//  ZJHImageManager.h
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"

@interface ZJHImageManager : NSObject

+ (ZJHImageManager*)defaultManager;

- (UIImage*)pokerSuitImage:(PBPoker*)poker;
- (UIImage*)pokerBodyImage:(PBPoker*)poker;
- (UIImage*)pokerRankImage:(PBPoker*)poker;

@end
