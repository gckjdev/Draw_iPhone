//
//  MyPaintButton.m
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintButton.h"

@implementation MyPaintButton
@synthesize clickButton = _clickButton;
@synthesize drawWord = _drawWord;
@synthesize background = _background;
@synthesize myPrintTag = _myPrintTag;
@synthesize delegate = _delegate;
- (void)dealloc
{
    [_background release];
    [_clickButton release];
    [_drawWord release];
    [_myPrintTag release];
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

+ (MyPaintButton*)createMypaintButtonWith:(UIImage*)buttonImage 
                                 drawWord:(NSString*)drawWord 
                              isDrawnByMe:(BOOL)isDrawnByMe 
                                 delegate:(id<MyPaintButtonDelegate>)delegate
{
    MyPaintButton* button = [MyPaintButton creatMyPaintButton];
    [button.myPrintTag setHidden:!isDrawnByMe];
    [button.drawWord setText:drawWord];
    [button.clickButton setImage:buttonImage forState:UIControlStateNormal];
    button.delegate = delegate;
    return button;
}

- (IBAction)clickImageButton:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickImage:)]) {
        [_delegate clickImage:self];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
