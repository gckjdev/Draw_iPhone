//
//  MyPaintButton.m
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintButton.h"
#import "MyPaint.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import <QuartzCore/QuartzCore.h>
#include <ImageIO/ImageIO.h>
#import "DrawUtils.h"
#import "ShareCell.h"
#import "ShareImageManager.h"
#import "TimeUtils.h"

@implementation MyPaintButton

@synthesize drawWord = _drawWord;
@synthesize myPrintTag = _myPrintTag;
@synthesize drawImage = _drawImage;
@synthesize paint = _paint;

- (void)dealloc
{
    PPRelease(_drawWord);
    PPRelease(_myPrintTag);
    PPRelease(_paint);
    PPRelease(_drawImage);
    [_holderView release];
    [super dealloc];
}

+ (MyPaintButton*)creatMyPaintButton
{
    MyPaintButton* button = [self createViewWithXibIdentifier:@"PaintButton"];
    
    [button.holderView setBackgroundColor:COLOR_GRAY];
    [button.drawWord setBackgroundColor:COLOR_YELLOW];
    if (ISIPAD) {
        [button.drawWord setFont:[UIFont systemFontOfSize:19]];
    }
    return button;
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
- (void)setInfo:(MyPaint *)paint
{
    self.paint = paint;
    [self.drawImage setImage:paint.thumbImage];
    NSString* word = paint.drawWord;
    if (paint.drawWord == nil || paint.drawWord.length == 0) {
        word = dateToString(paint.createDate);
    }
    if ([paint.isRecovery boolValue]){
        NSString* name = [NSString stringWithFormat:@"[%@] %@", NSLS(@"kRecoveryDraft"), word];
        [self.drawWord setText:name];
        [self.drawImage setImage:[ShareImageManager defaultManager].autoRecoveryDraftImage];
        
        
    }
    else{
        [self.drawWord setText:word];
    }

    [self.myPrintTag setHidden:!paint.drawByMe.boolValue];
    
    self.hidden = NO;
}
@end
