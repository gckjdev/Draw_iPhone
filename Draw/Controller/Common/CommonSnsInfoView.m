//
//  CommonSnsInfoView.m
//  Draw
//
//  Created by Orange on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonSnsInfoView.h"
#import "ShareImageManager.h"

@interface CommonSnsInfoView()

- (CGRect)calFrame:(CGRect)frame ByCount:(int)count;
- (NSMutableArray*)creatImageArraySina:(BOOL)hasSina 
                                    QQ:(BOOL)hasQQ 
                              Facebook:(BOOL)hasFacebook;

@end

@implementation CommonSnsInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame 
            hasSina:(BOOL)hasSina 
              hasQQ:(BOOL)hasQQ 
        hasFacebook:(BOOL)hasFacebook
{
    self = [super initWithFrame:frame];
    if (self) {
        int snsCount = (hasSina?1:0) + (hasQQ?1:0) + (hasFacebook?1:0);
        CGRect aFrame = [self calFrame:frame ByCount:snsCount];
        NSMutableArray* snsImageArray = [self creatImageArraySina:hasSina 
                                                               QQ:hasQQ 
                                                         Facebook:hasFacebook];
        for (int i = 0; i < snsImageArray.count; i ++) {
            UIView* view = [snsImageArray objectAtIndex:i];
            [view setFrame:CGRectMake(i*1.1*frame.size.height, 0, aFrame.size.height, aFrame.size.height)];
            [self addSubview:view];
        }
        
    }
    return self;
}

- (CGRect)calFrame:(CGRect)frame ByCount:(int)count
{
    if (frame.size.width >= frame.size.height*1.1*count) {
        return CGRectMake(0, 
                          0, 
                          frame.size.height*1.1*count, 
                          frame.size.height);
    } else {
        return CGRectMake(0, 
                          0, 
                          frame.size.width, 
                          frame.size.width/(count*1.1));
    }
}
- (NSMutableArray*)creatImageArraySina:(BOOL)hasSina 
                             QQ:(BOOL)hasQQ 
                       Facebook:(BOOL)hasFacebook
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
    if (hasSina) {
        [array addObject:[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].sinaWeiboImage]];
    }
    if (hasQQ) {
        [array addObject:[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].qqWeiboImage]];
    }
    if (hasFacebook) {
        [array addObject:[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].facebookImage]];
    }
    return array;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
