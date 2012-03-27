//
//  CommonDialog.m
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonDialog.h"

@implementation CommonDialog
@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (void)initTitles
{

}

+ (CommonDialog *)createDialog
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonDialog" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonDialog> but cannot find cell object from Nib");
        return nil;
    }
    CommonDialog* view =  (CommonDialog*)[topLevelObjects objectAtIndex:0];
    [view initTitles];
//    CAAnimation *runIn = [AnimationManager translationAnimationFrom:CGPointMake(160, 720) to:CGPointMake(160, 240) duration:0.3 delegate:self removeCompeleted:NO];
    //CAAnimation *rollAnimation = [AnimationManager rotationAnimationWithRoundCount:-3 duration:0.5];
//    [view.layer addAnimation:runIn forKey:@"runIn"];
    return view;
    
}

+ (CommonDialog *)createDialogwWithDelegate:(id<CommonDialogDelegate>)aDelegate
{
    CommonDialog* view = [CommonDialog createDialog];
    view.delegate = aDelegate;
    return view;
    
}

- (IBAction)clickOk:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk)]) {
        [_delegate clickOk];
    }
//    CAAnimation *runOut = [AnimationManager translationAnimationFrom:CGPointMake(160, 240) to:CGPointMake(160, 720) duration:0.1 delegate:self removeCompeleted:NO];
    // CAAnimation *rollAnimation = [AnimationManager rotationAnimationWithRoundCount:3 duration:0.5];
//    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
//    [runOut setDelegate:self];
//    [self.layer addAnimation:runOut forKey:@"runOut"];
    //[_contentView.layer addAnimation:rollAnimation forKey:@"rolling"];
    [self removeFromSuperview];
}

- (IBAction)clickBack:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(clickOk)]) {
        [_delegate clickOk];
    }
    [self removeFromSuperview];
}


//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    NSString* value = [anim valueForKey:@"AnimationKey"];
//    if ([value isEqualToString:@"runOut"]) {
//        [self setHidden:YES];
//        [self removeFromSuperview];
//    }
//}


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
