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

@implementation MyPaintButton

@synthesize wordsBackground = _wordsBackground;
@synthesize drawWord = _drawWord;
@synthesize background = _background;
@synthesize myPrintTag = _myPrintTag;
@synthesize drawImage = _drawImage;
@synthesize paint = _paint;

- (void)dealloc
{
    [_background release];
    [_drawWord release];
    [_myPrintTag release];
    [_wordsBackground release];
    [_paint release];
    [_drawImage release];
    [super dealloc];
}

+ (MyPaintButton*)creatMyPaintButton
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MyPaintButton" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <MyPaintButton> but cannot find cell object from Nib");
        return nil;
    }
    MyPaintButton* button =  (MyPaintButton*)[topLevelObjects objectAtIndex:0];
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
    
    if ([paint.isRecovery boolValue]){
        NSString* name = [NSString stringWithFormat:@"[%@] %@", NSLS(@"kRecoveryDraft"), paint.drawWord];
        [self.drawWord setText:name];
        [self.drawImage setImage:[ShareImageManager defaultManager].autoRecoveryDraftImage];
        
        
    }
    else{
        [self.drawWord setText:paint.drawWord];
    }

    [self.myPrintTag setHidden:!paint.drawByMe.boolValue];
    
    self.hidden = NO;
}
@end
