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

@interface OpusView ()

- (IBAction)clickOpusView:(id)sender;

@end

@implementation OpusView

AUTO_CREATE_VIEW_BY_XIB(OpusView)

- (void)dealloc
{
    PPRelease(_background);
    PPRelease(_opusTitle);
    PPRelease(_myOpusTag);
    PPRelease(_titleBackground);
    PPRelease(_opus);
    PPRelease(_opusImage);
    [super dealloc];
}

+ (id)createOpusView:(id<OpusViewDelegate>)delegate;
{  
    OpusView* view =  [OpusView createView];
    view.delegate = delegate;
    return view;
}
/*
+ (MyPaintButton*)createMypaintButtonWith:(UIImage*)buttonImage 
                                 drawWord:(NSString*)drawWord 
                              isDrawnByMe:(BOOL)isDrawnByMe 
                                 delegate:(id<MyPaintButtonDelegate>)delegate
{
    MyPaintButton* button = [MyPaintButton creatMyPaintButton];
    [button.myPrintTag setHidden:!isDrawnByMe];
    [button.drawWord setText:drawWord];
    button.delegate = delegate;
    return button;
}
*/

#define TITLE_FONT_SIZE (ISIPAD?18:9)
- (void)updateWithOpus:(Opus *)opus
{
    self.opus = opus;
    NSString* title = opus.name;
    if (title == nil || title.length == 0) {
        title = dateToString(opus.createDate);
    }
    if ([opus.pbOpus isRecovery]){
        NSString* name = [NSString stringWithFormat:@"[%@] %@", NSLS(@"kRecoveryDraft"), title];
        [self.opusTitle setText:name];
        [self.opusImage setImage:[ShareImageManager defaultManager].autoRecoveryDraftImage];
    }
    else{
        [self.opusTitle setText:title];
        [self.opusImage setImageWithURL:[NSURL URLWithString:opus.pbOpus.thumbImage]];
    }

    [self.myOpusTag setHidden:![opus isMyOpus]];
    [self.opusTitle setFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE]];
    self.hidden = NO;
}

- (IBAction)clickOpusView:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOpus:)]) {
        [_delegate didClickOpus:self.opus];
    }
}
@end
