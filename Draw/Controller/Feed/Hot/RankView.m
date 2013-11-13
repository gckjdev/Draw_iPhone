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
#import "UIImageExt.h"
#import "ContestManager.h"
#import "PPConfigManager.h"
#import "WhisperStyleView.h"

@interface RankView ()
@property (retain, nonatomic) IBOutlet UILabel *costLabel;
@property (retain, nonatomic) IBOutlet UILabel *boughtCountLabel;

@end


@implementation RankView
@synthesize drawFlag = _drawFlag;
@synthesize maskControl = _maskControl;
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
        case RankViewTypeWhisper:
            identifier = @"WhisperView";
            break;
        default:
            return nil;
    }
    RankView *view = [self createViewWithXibIdentifier:identifier];
    view.delegate = delegate;
    
    [view setClipsToBounds:YES];
    [view.drawImage setContentMode:UIViewContentModeScaleAspectFill];
    view.maskControl = [[[UIControl alloc] initWithFrame:view.bounds] autorelease];
    [view.maskControl addTarget:view action:@selector(clickMaskView:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:view.maskControl];
    
    view.backgroundColor = COLOR_GRAY;
    view.holderView.layer.cornerRadius = 8;
    
    return view;
}

- (void)dealloc {
//    PPDebug(@"<RankView> = %@, dealloc", self);
    
    PPRelease(_feed);
    PPRelease(_title);
    PPRelease(_author);
    PPRelease(_drawImage);
    PPRelease(_drawFlag);
    PPRelease(_maskControl);
    PPRelease(_cupFlag);
    [_costLabel release];
    [_boughtCountLabel release];
    [_holderView release];
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
       
        defaultImage = [[ShareImageManager defaultManager] unloadBg];
       
       [self.drawImage setImageWithURL:url placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
          
           if (error != nil) {
               self.drawImage.alpha = 1;
           }else{
               
                if (cacheType == SDImageCacheTypeNone) {
                    self.drawImage.alpha = 0;
                }

                [UIView animateWithDuration:1 animations:^{
                    self.drawImage.alpha = 1.0;
                }];
                [self updateImage:image];
           }
           
       }];
       
       
    }else{
        PPDebug(@"<setViewInfo> Old Opus, no image to show. feedId=%@,word=%@", 
                feed.feedId,feed.wordText);
        [self.drawImage setImage:[[ShareImageManager defaultManager] unloadBg]];
    }
    
    feed.drawData = nil;
    feed.pbDrawData = nil;
    
    if (feed.showAnswer && !([GameApp disableEnglishGuess] && [[UserManager defaultManager] getLanguageType] != ChineseType)) {
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

    if ([PPConfigManager showAuthorOnOpus]){
        NSString *author = [NSString stringWithFormat:@" %@",feed.feedUser.nickName];
        [self.author setText:author];
    }
    else{
        NSString* desc = feed.opusDesc;
        if ([desc length] == 0){
            desc = feed.wordText;
        }
        desc = [NSString stringWithFormat:@" %@", desc];
        [self.author setText:desc];
    }
    
    [self setRankViewSelected:NO];
    
    self.maskControl.frame = self.bounds;
    
    if (feed.learnDraw) {
        [self updateLearnDraw:feed.learnDraw];
    }

    if (self.feed.categoryType == PBOpusCategoryTypeSingCategory) {
        [[self.drawImage viewWithTag:201139481] removeFromSuperview];
        WhisperStyleView *v = [WhisperStyleView createWithFrame:self.drawImage.bounds feed:self.feed];
        [self.drawImage addSubview:v];
        v.tag = 201139481;
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
    if (self.feed.showAnswer && !([GameApp disableEnglishGuess] && [[UserManager defaultManager] getLanguageType] != ChineseType)) {
        [self.title setText:self.feed.wordText];
    }
    self.author.hidden = YES;
    [self.title setTextAlignment:UITextAlignmentCenter];
}

- (void)updateViewInfoForContestOpus:(DrawFeed*)feed
{
    [self.title setHidden:YES];
    
    if ([[ContestManager defaultManager] displayContestAnonymousForFeed:feed]){
        self.author.hidden = YES;
    }
    else{
        self.author.hidden = NO;
    }    
}

- (void)setRankViewSelected:(BOOL)selected
{
    [self.maskControl setSelected:selected];
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
            return [DeviceDetection isIPAD] ? 245 : 99;
        case RankViewTypeWhisper:
            return ISIPAD ? 384 : 159;
        default:
            return 0;
    }
}

@end
