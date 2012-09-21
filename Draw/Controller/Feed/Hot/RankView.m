//
//  RankView.m
//  Draw
//
//  Created by  on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RankView.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "DrawFeed.h"

@implementation RankView
@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize author = _author;
@synthesize drawImage = _drawImage;




+ (id)createRankView:(id)delegate type:(RankViewType)type
{
    NSString* identifier = nil;
    switch (type) {
        case RankViewTypeFirst:
            identifier = @"RankFirstView";
            break;
        case RankViewTypeSecond:
            identifier = @"RankSecondView";
            break;
        case RankViewTypeNormal:
            identifier = @"RankView";
            break;
        default:
            return nil;
    }
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    RankView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}

- (void)dealloc {
    [_title release];
    [_author release];
    [_drawImage release];
    [super dealloc];
}


- (void)setViewInfo:(DrawFeed *)feed
{
    if (feed == nil) {
        self.hidden = YES;
        return;
    }
    [self.drawImage clear];
    [self.drawImage setUrl:[NSURL URLWithString:feed.drawImageUrl]];
    [GlobalGetImageCache() manage:self.drawImage];
    
    [self.title setText:feed.wordText];
    [self.author setText:feed.feedUser.nickName];
}

+ (CGFloat)heightForRankViewType:(RankViewType)type
{
    switch (type) {
        case RankViewTypeFirst:
            return [DeviceDetection isIPAD] ? 137 : 137;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 167 : 167;
        case RankViewTypeNormal:
            return [DeviceDetection isIPAD] ? 109 : 109;
        default:
            return 0;
    }
}

+ (CGFloat)widthForRankViewType:(RankViewType)type
{
    switch (type) {
        case RankViewTypeFirst:
            return [DeviceDetection isIPAD] ? 320 : 320;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 159 : 159;
        case RankViewTypeNormal:
            return [DeviceDetection isIPAD] ? 105 : 105;
        default:
            return 0;
    }
}

@end
