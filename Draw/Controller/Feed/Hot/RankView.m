//
//  RankView.m
//  Draw
//
//  Created by  on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RankView.h"

@implementation RankView
@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize author = _author;




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
    [super dealloc];
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

@end
