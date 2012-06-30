//
//  CommonSnsInfoView.m
//  Draw
//
//  Created by Orange on 12-6-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonSnsInfoView.h"
#import "ShareImageManager.h"
#import "PPDebug.h"

#define SNS_VIEW_TAG_OFFSET 20120630
#define MAX_SNS_COUNT 3

@interface CommonSnsInfoView()

- (CGRect)calFrame:(CGRect)frame ByCount:(int)count;

@end

@implementation CommonSnsInfoView
@synthesize sinaImageView = _sinaImageView;
@synthesize qqImageView = _qqImageView;
@synthesize facebookImageView = _facebookImageView;

- (void)dealloc
{
    PPRelease(_sinaImageView);
    PPRelease(_qqImageView);
    PPRelease(_facebookImageView);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sinaImageView = [[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].sinaWeiboImage] autorelease];
        self.qqImageView = [[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].qqWeiboImage] autorelease];
        self.facebookImageView = [[[UIImageView alloc] initWithImage:[ShareImageManager defaultManager].facebookImage] autorelease];
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
        [self initWithFrame:frame];
        [self addSubview:_sinaImageView];
        [self addSubview:_qqImageView];
        [self addSubview:_facebookImageView];
        [self setHasSina:hasSina 
                   hasQQ:hasQQ 
             hasFacebook:hasFacebook];
    }
    return self;
}

- (CGRect)calFrame:(CGRect)frame ByCount:(int)count
{
    if (frame.size.width >= frame.size.height*count) {
        return CGRectMake(0, 
                          0, 
                          frame.size.height*count, 
                          frame.size.height);
    } else {
        return CGRectMake(0, 
                          0, 
                          frame.size.width, 
                          frame.size.width/count);
    }
}

- (void)setHasSina:(BOOL)hasSina 
             hasQQ:(BOOL)hasQQ 
       hasFacebook:(BOOL)hasFacebook
{
    [_sinaImageView setHidden:YES];
    [_qqImageView setHidden:YES];
    [_facebookImageView setHidden:YES];
    
    int snsCount = (hasSina?1:0) + (hasQQ?1:0) + (hasFacebook?1:0);
    CGRect aFrame = [self calFrame:self.frame ByCount:snsCount];
    CGPoint point = CGPointMake(0, 0);
    if (hasSina) {
        [_sinaImageView setFrame:CGRectMake(point.x, point.y, aFrame.size.height, aFrame.size.height)];
        point.x += aFrame.size.height;
        [_sinaImageView setHidden:NO];
    }
    if (hasQQ) {
        [_qqImageView setFrame:CGRectMake(point.x, point.y, aFrame.size.height, aFrame.size.height)];
        point.x += aFrame.size.height;
        [_qqImageView setHidden:NO];
    }
    if (hasFacebook) {
        [_facebookImageView setFrame:CGRectMake(point.x, point.y, aFrame.size.height, aFrame.size.height)];
        point.x += aFrame.size.height;
        [_facebookImageView setHidden:NO];
    }
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
