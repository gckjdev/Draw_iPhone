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
#import "ShowDrawView.h"
#import "DrawUtils.h"
#import "Draw.h"
#import "ShareImageManager.h"

@implementation RankView
@synthesize drawFlag = _drawFlag;
@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize author = _author;
@synthesize drawImage = _drawImage;
@synthesize feed = _feed;



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
    PPRelease(_feed);
    PPRelease(_title);
    PPRelease(_author);
    PPRelease(_drawImage);
    [_drawFlag release];
    [super dealloc];
}


- (void)setViewInfo:(DrawFeed *)feed
{
    if (feed == nil) {
        self.hidden = YES;
        return;
    }
    self.feed = feed;
    [self.drawImage clear];
    [self.drawImage setImage:[[ShareImageManager defaultManager] unloadBg]];
    if(feed.drawImage){
        [self.drawImage setImage:feed.drawImage];
    }else if ([feed.drawImageUrl length] != 0) {
        [self.drawImage setUrl:[NSURL URLWithString:feed.drawImageUrl]];
    }else{
        PPDebug(@"<setViewInfo> show draw view. feedId=%@,word=%@", 
                feed.feedId,feed.wordText);
        
        ShowDrawView *showView = [[ShowDrawView alloc] initWithFrame:self.drawImage.frame];
        CGFloat xScale = self.bounds.size.width / DRAW_VIEW_FRAME.size.width;
        CGFloat yScale = self.bounds.size.height / DRAW_VIEW_FRAME.size.height;
        NSMutableArray *list = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
        [showView setDrawActionList:list];
        [self insertSubview:showView aboveSubview:self.drawImage];
        [showView release];
        [showView show];
        UIImage *image = [showView createImage];
        [self.drawImage setImage:image];
        feed.drawImage = image;
        [showView removeFromSuperview];
        feed.drawData = nil;

    }
    [GlobalGetImageCache() manage:self.drawImage];  
    
    if (feed.showAnswer) {
        [self.title setText:feed.wordText];        
    }else{
        self.title.hidden = YES;
    }

    if ([feed isMyOpus]) {
        self.drawFlag.image = [[ShareImageManager defaultManager] myPaintImage];
    }else if ([feed hasGuessed]) {
        self.drawFlag.image = [[ShareImageManager defaultManager] rightImage];
    }else{
        self.drawFlag.hidden = YES;
    }
    
    [self.author setText:feed.feedUser.nickName];
    
    //add a button.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.bounds;
    [button addTarget:self action:@selector(clickRankView:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)clickRankView:(id)sender
{
    if (self.delegate && 
        [self.delegate respondsToSelector:@selector(didClickRankView:)]) {
        [self.delegate didClickRankView:self];
    }
}

+ (CGFloat)heightForRankViewType:(RankViewType)type
{
    switch (type) {
        case RankViewTypeFirst:
            return [DeviceDetection isIPAD] ? 137 : 137;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 167 : 167;
        case RankViewTypeNormal:
            return [DeviceDetection isIPAD] ? 110 : 110;
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
            return [DeviceDetection isIPAD] ? 106 : 106;
        default:
            return 0;
    }
}

@end
