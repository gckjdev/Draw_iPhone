//
//  MyPaintButton.m
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyPaintButton.h"

@implementation MyPaintButton
@synthesize wordsBackground = _wordsBackground;
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
    [_wordsBackground release];
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
        _background = [[UIImageView alloc] init];
        _wordsBackground = [[UIImageView alloc] init];
        _myPrintTag = [[UIImageView alloc] init];
        _clickButton = [[UIButton alloc] init];
        _drawWord = [[UILabel alloc] init];
        [self setBackgroundColor:[UIColor clearColor]];
        [_background setImage:[UIImage imageNamed:@"user_picbg.png"]];
        [_wordsBackground setImage:[UIImage imageNamed:@"easy.png"]];
        [_myPrintTag setImage:[UIImage imageNamed:@"print_tip.png"]];
        
        [_background setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.8)];
        [_wordsBackground setFrame:CGRectMake(0, self.frame.size.height*0.8, self.frame.size.width, self.frame.size.height*0.2)];
        [_myPrintTag setFrame:CGRectMake(_background.frame.size.width-16, _background.frame.size.height-17, 16, 17)];
        [_drawWord setFrame:_wordsBackground.frame];
        [_clickButton setFrame:CGRectMake(4, 4, self.frame.size.width-8, self.frame.size.height*0.8-8)];
        [_clickButton addTarget:self action:@selector(clickImageButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_drawWord setTextAlignment:UITextAlignmentCenter];
        [_drawWord setFont:[UIFont systemFontOfSize:10]];
        [_drawWord setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:_background];
        [self addSubview:_wordsBackground];
        [self addSubview:_clickButton];
        [self addSubview:_myPrintTag];
        [self addSubview:_drawWord];
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
