//
//  MyPaintButton.m
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OpusView.h"
#import "Opus.h"
#import "PPDebug.h"
#import <QuartzCore/QuartzCore.h>
#include <ImageIO/ImageIO.h>
#import "ShareImageManager.h"
#import "TimeUtils.h"
#import "AutoCreateViewByXib.h"
#import "UIImageView+WebCache.h"
#import "DrawFeed.h"

@interface OpusView ()

@property (retain, nonatomic) Opus* opus;
@property (retain, nonatomic) DrawFeed *feed;

@end

@implementation OpusView

AUTO_CREATE_VIEW_BY_XIB(OpusView)

- (void)dealloc
{
    PPRelease(_background);
    PPRelease(_opusTitle);
    PPRelease(_titleBackground);
    PPRelease(_opus);
    PPRelease(_opusImage);
    PPRelease(_feed);
    [super dealloc];
}

+ (id)createOpusView:(id<OpusViewDelegate>)delegate;
{  
    OpusView* view =  [OpusView createView];
    view.delegate = delegate;
    
    view.opusTitle.textColor = COLOR_BROWN;
    view.opusTitle.backgroundColor = COLOR_YELLOW;
    
    return view;
}

#define TITLE_FONT_SIZE (ISIPAD?18:9)
- (void)updateWithOpus:(Opus *)opus
{
    self.opus = opus;
    NSString* title = opus.name;
    if (title == nil || title.length == 0) {
        title = dateToString(opus.createDate);
    }
    
    if (opus.pbOpus.isRecovery) {
        NSString* name = [NSString stringWithFormat:@"[%@] %@", NSLS(@"kRecoveryDraft"), title];
        [self.opusTitle setText:name];
        [self.opusImage setImage:[ShareImageManager defaultManager].autoRecoveryDraftImage];
    }else{
        
        [self.opusTitle setText:title];
        UIImage *image = [UIImage imageWithContentsOfFile:opus.pbOpus.localThumbImageUrl];
        [self.opusImage setImage:image];
    }

//    [self.myOpusTag setHidden:![opus isMyOpus]];
    [self.opusTitle setFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    self.hidden = NO;
}

- (void)updateWithFeed:(DrawFeed *)feed{

    self.feed = feed;
    
    NSString* title = self.feed.wordText;
    
    if (title == nil || title.length == 0) {
        title = dateToString(feed.createDate);
    }
    
    [self.opusTitle setText:title];
    [self.opusImage setImageWithURL:feed.thumbURL];
    
    //    [self.myOpusTag setHidden:![opus isMyOpus]];
    [self.opusTitle setFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    self.hidden = NO;
}

- (IBAction)clickOpusView:(id)sender
{
    if (_isDraft) {
        if (_delegate && [_delegate respondsToSelector:@selector(didClickOpus:)]) {
            [_delegate didClickOpus:self.opus];
        }
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(didClickFeed:)]) {
            [_delegate didClickFeed:self.feed];
        }
    }
}
@end
