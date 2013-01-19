//
//  CommentHeaderView.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentHeaderView.h"

@implementation CommentHeaderView
@synthesize delegate = _delegate;
@synthesize feed = _feed;

- (void)dealloc
{
    PPDebug(@"%@ dealloc",self);
    PPRelease(_feed);
    [super dealloc];
}

#define CHANGE_TIMES 100

- (UIView *)splitLineWithType:(CommentType)type
{
    NSInteger tag = type * CHANGE_TIMES;
    return [self viewWithTag:tag];
    
}

- (UIButton *)buttonWithType:(CommentType)type
{
    if (type == CommentTypeNO) {
        return nil;
    }
    UIButton *b = (UIButton *)[self viewWithTag:type];
    return b;
}


- (IBAction)clickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self setSeletType:button.tag];
}


+ (id)createCommentHeaderView:(id)delegate
{
    NSString* identifier = @"CommentHeaderView";
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    CommentHeaderView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}
- (void)setSeletType:(CommentType)type
{
    if (_currentType == type) {
        return;
    }
    UIButton *button = [self buttonWithType:type];
    UIButton *b1 = [self buttonWithType:_currentType];
    [b1 setSelected:NO];
    [button setSelected:YES];

    _currentType = type;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCommentType:)]) {
        [self.delegate didSelectCommentType:_currentType];
    }
}
- (CommentType)seletedType
{
    return _currentType;
}


- (UIButton *)previousButtonWithType:(CommentType)type
{
    switch (type) {
        case CommentTypeGuess:
            return [self buttonWithType:CommentTypeComment];
        case CommentTypeFlower:
            return [self buttonWithType:CommentTypeGuess];
        case CommentTypeTomato:
            return [self buttonWithType:CommentTypeFlower];
        case CommentTypeComment:
        default:
            return nil;
    }
}

#define ADD_WIDTH ([DeviceDetection isIPAD] ? 24 : 10) 
#define BUTTON_START ([DeviceDetection isIPAD] ? 6 : 2) 
- (void)updateButtonFrameWityType:(CommentType)type size:(CGSize)size
{
    UIButton *previousButton = [self previousButtonWithType:type];
    CGFloat x = BUTTON_START;
    if (previousButton) {
        x =  CGRectGetMaxX(previousButton.frame);
    }
    CGFloat width = size.width + ADD_WIDTH;
    UIButton *button = [self buttonWithType:type];
    button.frame = CGRectMake(x, 0, width, [CommentHeaderView getHeight]);
}

- (CGPoint)splitLineCenter:(CommentType)type
{
    UIButton *button = [self buttonWithType:type];
    UIButton *prevButton = [self previousButtonWithType:type];
    CGFloat x = (button.frame.origin.x + (prevButton.frame.size.width + prevButton.frame.origin.x)) * 0.5;
    return CGPointMake(x, [CommentHeaderView getHeight] *0.5);
}

- (void)updateSplitLines
{
    //update comment | guess
    UIView *line = [self splitLineWithType:CommentTypeGuess];
    if ([self.feed isContestFeed]) {
        line.hidden = YES;
    }else{
        [line setCenter:[self splitLineCenter:CommentTypeGuess]];
    }
    //update guess | flower
    line = [self splitLineWithType:CommentTypeFlower];
    [line setCenter:[self splitLineCenter:CommentTypeFlower]];
    
    //update flower | tomato
    line = [self splitLineWithType:CommentTypeTomato];
    [line setCenter:[self splitLineCenter:CommentTypeTomato]];
}

- (void)updateButtonWithType:(CommentType)type 
                       times:(NSInteger)times 
                      format:(NSString *)format
{    
    UIButton *button = [self buttonWithType:type];
    NSString *title = [NSString stringWithFormat:format,times];
    [button setTitle:title forState:UIControlStateNormal];
    //update frame
    CGSize size = [title sizeWithFont:button.titleLabel.font];
    [self updateButtonFrameWityType:type size:size];
}
- (void)setViewInfo:(DrawFeed *)feed
{
    [self updateTimes:feed];
    [self updateSplitLines];
}
+ (CGFloat)getHeight
{
    if ([DeviceDetection isIPAD]) {
        return 50;
    }
    return 25;
}

- (void)updateTimes:(DrawFeed *)feed
{
    [self updateButtonWithType:CommentTypeComment 
                         times:feed.commentTimes 
                        format:NSLS(@"kCommentTimes")];
    if (![feed isContestFeed]) {
        [self updateButtonWithType:CommentTypeGuess 
                             times:feed.guessTimes 
                            format:NSLS(@"kGuessTimes")];        
    }else{
        UIButton *button = [self buttonWithType:CommentTypeGuess];
        UIButton *prev = [self previousButtonWithType:CommentTypeGuess];
        button.hidden = YES;
        button.frame = prev.frame;
    }
    
    [self updateButtonWithType:CommentTypeFlower
                         times:feed.flowerTimes 
                        format:NSLS(@"kFlowerTimes")];
    
    [self updateButtonWithType:CommentTypeTomato
                         times:feed.tomatoTimes 
                        format:NSLS(@"kTomatoTimes")];
}

@end
