//
//  CommonDialog.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"
#import "AnimationManager.h"

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@implementation CommonDialog
@synthesize contentView = _contentView;
@synthesize oKButton = _OKButton;
@synthesize backButton = _backButton;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_contentView release];
    [_OKButton release];
    [_backButton release];
    [super dealloc];
}

- (void)initTitles
{

}

- (void)initButtonsWithStyle:(CommonDialogStyle)aStyle
{
    switch (aStyle) {
        case SINGLE_BUTTON: {
            [self.oKButton setFrame:CGRectMake(88, 105, 144, 37)];
            [self.backButton setHidden:YES];
        }
            break;
        case DOUBLE_BUTTON: {
            
        }
            break;
        default:
            break;
    }
}

+ (CommonDialog *)createDialogWithStyle:(CommonDialogStyle)aStyle
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonDialog" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonDialog> but cannot find cell object from Nib");
        return nil;
    }
    CommonDialog* view =  (CommonDialog*)[topLevelObjects objectAtIndex:0];
    [view initButtonsWithStyle:aStyle];
    [view initTitles];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:view removeCompeleted:NO];
    //CAAnimation *rollAnimation = [AnimationManager rotationAnimationWithRoundCount:-3 duration:0.5];
    [view.contentView.layer addAnimation:runIn forKey:@"runIn"];
    return view;
    
}

+ (CommonDialog *)createDialogwWithDelegate:(id<CommonDialogDelegate>)aDelegate withStyle:(CommonDialogStyle)aStyle
{
    CommonDialog* view = [CommonDialog createDialogWithStyle:aStyle];
    view.delegate = aDelegate;
    return view;
    
}

- (IBAction)clickOk:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk)]) {
        [_delegate clickOk];
    }
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
//     CAAnimation *rollAnimation = [AnimationManager rotationAnimationWithRoundCount:3 duration:0.5];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
//    [runOut setDelegate:self];
//    [self.layer addAnimation:runOut forKey:@"runOut"];
    [_contentView.layer addAnimation:runOut forKey:@"runOut"];
    //[self removeFromSuperview];
}

- (IBAction)clickBack:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk)]) {
        [_delegate clickOk];
    }
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:RUN_OUT_TIME delegate:self removeCompeleted:NO];
    //     CAAnimation *rollAnimation = [AnimationManager rotationAnimationWithRoundCount:3 duration:0.5];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    //    [runOut setDelegate:self];
    //    [self.layer addAnimation:runOut forKey:@"runOut"];
    [_contentView.layer addAnimation:runOut forKey:@"runOut"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
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
