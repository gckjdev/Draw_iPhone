//
//  RankView.m
//  Draw
//
//  Created by  on 12-9-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RankView.h"
#import "PPApplication.h"
#import "DrawFeed.h"
#import "ShowDrawView.h"
#import "DrawUtils.h"
#import "Draw.h"
#import "ShareImageManager.h"
#import "FeedManager.h"
#import "FeedService.h"
#import "UIViewUtils.h"
#import "LearnDrawManager.h"

@interface RankView ()
@property (retain, nonatomic) IBOutlet UILabel *costLabel;
@property (retain, nonatomic) IBOutlet UILabel *boughtCountLabel;

@end


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
        case RankViewTypeDrawOnCell:
            identifier = @"DrawOnCell";
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
                              highlightMaskImage];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateHighlighted];
    [view.maskButton setBackgroundImage:selectedImage 
                               forState:UIControlStateSelected];
    [view.maskButton setAlpha:0.8];
    [view setClipsToBounds:YES];
    [view.drawImage setContentMode:UIViewContentModeScaleAspectFill];
    return view;
}

- (void)dealloc {
    PPRelease(_feed);
    PPRelease(_title);
    PPRelease(_author);
    PPRelease(_drawImage);
    PPRelease(_drawFlag);
    PPRelease(_maskButton);
    PPRelease(_cupFlag);
    [_costLabel release];
    [_boughtCountLabel release];
    [super dealloc];
}


- (void)updateImage:(UIImage *)image
{
    [self.drawImage setImage:image];
}

- (void)updateLearnDraw:(PBLearnDraw *)learnDraw
{
    [self.costLabel setText:[NSString stringWithFormat:@"%d", learnDraw.price]];
    [self.boughtCountLabel setText:[NSString stringWithFormat:@"%d", learnDraw.boughtCount]];
    [self.drawFlag setHidden:![[LearnDrawManager defaultManager] hasBoughtDraw:self.feed.feedId]];
}

- (void)setViewInfo:(DrawFeed *)feed
{
    if (feed == nil) {
        self.hidden = YES;
        return;
    }
    self.feed = feed;
    

    
   if ([feed.drawImageUrl length] != 0) {
       NSURL *url = nil;//[NSURL URLWithString:feed.drawImageUrl];

       if (CGRectGetWidth(self.bounds) > 301) {
           url = feed.largeImageURL;
       }else{
           url = feed.thumbURL;
       }
       
       
        UIImage *defaultImage = nil;
       
        if(feed.largeImage){
            defaultImage = feed.largeImage;
        }
        else{
            defaultImage = [[ShareImageManager defaultManager] unloadBg];
        }
        [self.drawImage setImageWithURL:url
                       placeholderImage:defaultImage
                                success:^(UIImage *image, BOOL cached) {
            self.drawImage.alpha = 0;
            [UIView animateWithDuration:1 animations:^{
                self.drawImage.alpha = 1.0;
            }];
            feed.largeImage = image;
            [self updateImage:image];
        } failure:^(NSError *error) {
            self.drawImage.alpha = 1;
        }];
    }else{
        PPDebug(@"<setViewInfo> Old Opus, no image to show. feedId=%@,word=%@", 
                feed.feedId,feed.wordText);
        [self.drawImage setImage:[[ShareImageManager defaultManager] unloadBg]];
    }
    
    feed.drawData = nil;
    feed.pbDrawData = nil;
    
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
    
    if (feed.learnDraw) {
        [self updateLearnDraw:feed.learnDraw];
    }

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

- (void)updateViewInfoForContestOpus
{
    [self.title setHidden:YES];
    [self.author setHidden:NO];
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
    //old height
    
    switch (type) {
        case RankViewTypeFirst:
            return [DeviceDetection isIPAD] ? 268 : 123;
        case RankViewTypeSecond:
            return [DeviceDetection isIPAD] ? 300 : 130;
//        case RankViewTypeNormal:
//            return [DeviceDetection isIPAD] ? 244 : 110;
//        case RankViewTypeDrawOnCell:
//            return [DeviceDetection isIPAD] ? 220 : 99;
        default:
            return [RankView widthForRankViewType:type];
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
        case RankViewTypeDrawOnCell:            
            return [DeviceDetection isIPAD] ? 230 : 99;
        default:
            return 0;
    }
}

@end
