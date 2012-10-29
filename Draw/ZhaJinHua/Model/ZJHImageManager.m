//
//  ZJHImageManager.m
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import "ZJHImageManager.h"

static ZJHImageManager* shareInstance;

@implementation ZJHImageManager

+ (ZJHImageManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[ZJHImageManager alloc] init];
    }
    return shareInstance;
}

- (UIImage*)pokerSuitImage:(PBPoker*)poker
{
    return nil;
}
- (UIImage*)pokerBodyImage:(PBPoker*)poker
{
    return nil;
}
- (UIImage*)pokerRankImage:(PBPoker*)poker
{
    return nil;
}

@end
