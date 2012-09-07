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
    UIButton *b1 = [self buttonWithType:_currentType];
    [b1 setSelected:NO];
    [button setSelected:YES];
    _currentType = button.tag;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCommentType:)]) {
        [self.delegate didSelectCommentType:_currentType];
    }
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

#define ADD_WIDTH 10
#define BUTTON_START 2
- (void)updateButtonFrameWityType:(CommentType)type size:(CGSize)size
{
    UIButton *previousButton = [self previousButtonWithType:type];
    CGFloat x = BUTTON_START;
    if (previousButton) {
        x = previousButton.frame.origin.x + previousButton.frame.size.width;
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
    [line setCenter:[self splitLineCenter:CommentTypeGuess]];
    
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
    _currentType = CommentTypeNO;
    [self clickButton:[self buttonWithType:CommentTypeComment]];
}
+ (CGFloat)getHeight
{
    return 37;
}

- (void)updateTimes:(DrawFeed *)feed
{
    [self updateButtonWithType:CommentTypeComment 
                         times:feed.commentTimes 
                        format:NSLS(@"kCommentTimes")];
    
    [self updateButtonWithType:CommentTypeGuess 
                         times:feed.guessTimes 
                        format:NSLS(@"kGuessTimes")];
    
    [self updateButtonWithType:CommentTypeFlower
                         times:feed.flowerTimes 
                        format:NSLS(@"kFlowerTimes")];
    
    [self updateButtonWithType:CommentTypeTomato
                         times:feed.tomatoTimes 
                        format:NSLS(@"kTomatoTimes")];
}

@end
