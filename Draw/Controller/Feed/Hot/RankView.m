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
@synthesize maskButton = _maskButton;
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
    
    UIImage *selectedImage = [[ShareImageManager defaultManager] 
                              normalButtonImage];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateHighlighted];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateSelected];
    [view.maskButton setAlpha:0.8];
    return view;
}

- (void)dealloc {
    PPRelease(_feed);
    PPRelease(_title);
    PPRelease(_author);
    PPRelease(_drawImage);
    [_drawFlag release];
    [_maskButton release];
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
        
        [[ShareImageManager defaultManager] saveFeedImage:image withImageName:feed.feedId asyn:YES];
    }
    [GlobalGetImageCache() manage:self.drawImage];  
    
    if (feed.showAnswer) {
        NSString *answer = [NSString stringWithFormat:@" %@",feed.wordText];
        [self.title setText:answer];        
    }else{
        self.title.hidden = YES;
    }

    if ([feed hasGuessed]) {
        self.drawFlag.image = [[ShareImageManager defaultManager] rightImage];
    }else{
        self.drawFlag.hidden = YES;
    }
    
    NSString *author = [NSString stringWithFormat:@" %@",feed.feedUser.nickName];
    [self.author setText:author];
    [self setRankViewSelected:NO];
    
    self.drawImage.center = self.center;
    self.maskButton.frame = self.bounds;
}

- (void)updateViewInfoForMyOpus
{
    self.title.frame = self.author.frame;
    [self.title setText:self.feed.wordText];
    self.title.hidden = NO;
    self.author.hidden = YES;
    self.drawFlag.hidden = YES;
    [self.title setTextAlignment:UITextAlignmentCenter];
}
- (void)updateViewInfoForUserOpus
{
    self.title.frame = self.author.frame;
    if (self.feed.showAnswer) {
        [self.title setText:self.feed.wordText];
    }
    self.author.hidden = YES;
    [self.title setTextAlignment:UITextAlignmentCenter];
}

- (void)setRankViewSelected:(BOOL)selected
{
    [self.maskButton setSelected:selected];
}

- (IBAction)clickMaskView:(id)sender
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
            return [DeviceDetection isIPAD] ? 268 : 123;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 306 : 139;
        case RankViewTypeNormal:
            return [DeviceDetection isIPAD] ? 244 : 110;
        default:
            return 0;
    }
}

+ (CGFloat)widthForRankViewType:(RankViewType)type
{
    switch (type) {
        case RankViewTypeFirst:
            return [DeviceDetection isIPAD] ? 768 : 320;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 384 : 159;
        case RankViewTypeNormal:
            return [DeviceDetection isIPAD] ? 256 : 106;
        default:
            return 0;
    }
}

@end
