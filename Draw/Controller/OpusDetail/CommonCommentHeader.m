//
//  CommonCommentHeader.m
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import "CommonCommentHeader.h"
#import "UIButton+Extend.h"
#import "PBOpus+Extend.h"

@interface CommonCommentHeader()
@property (retain, nonatomic) PBOpus *opus;

@end

@implementation CommonCommentHeader

- (void)dealloc
{
    [_opus release];
    [super dealloc];
}

#define CHANGE_TIMES 100

+ (NSString*)getHeaderIdentifier
{
    return @"CommonCommentHeader";
}


+ (CGFloat)getHeaderHeight
{
    if ([DeviceDetection isIPAD]) {
        return 50;
    }
    return 25;
}

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

- (void)setSeletType:(CommentType)type
{
    if (_currentType == type) {
        return;
    }
    
    if (type == CommentTypeSave) {
        [(PPViewController *)[self theViewController] popupHappyMessage:NSLS(@"kNoSaveList") title:nil];
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
        case CommentTypeSave:
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
    button.frame = CGRectMake(x, 0, width, [CommonCommentHeader getHeaderHeight]);
}

- (CGPoint)splitLineCenter:(CommentType)type
{
    UIButton *button = [self buttonWithType:type];
    UIButton *prevButton = [self previousButtonWithType:type];
//    CGFloat x = (button.frame.origin.x + (prevButton.frame.size.width + prevButton.frame.origin.x)) * 0.5;
    
//    CGFloat x = prevButton.frame.origin.x + prevButton.frame.size.width + ;

    CGFloat x = (CGRectGetMaxX(prevButton.frame) + CGRectGetMinX(button.frame)) / 2;
    
//    CGFloat x = (CGRectGetMaxX(prevButton.frame) + (button.frame.origin.x - CGRectGetMaxX(prevButton.frame) / 2);

    PPDebug(@"preButton(%@), rect = %@, button(%@), rect = %@, x = %f \n\n",
            [prevButton titleForState:UIControlStateNormal],
            NSStringFromCGRect(prevButton.frame),
            [button titleForState:UIControlStateNormal],
            NSStringFromCGRect(button.frame), x);
    
    
    return CGPointMake(x, [CommonCommentHeader getHeaderHeight] *0.5);
}

- (void)updateSplitLines
{
    //update comment | guess
    UIView *line = [self splitLineWithType:CommentTypeGuess];
    if ([_opus isContestOpus]) {
        line.hidden = YES;
    }else{
        line.hidden = NO;
        [line setCenter:[self splitLineCenter:CommentTypeGuess]];
    }
    //update guess | flower
    line = [self splitLineWithType:CommentTypeFlower];
    [line setCenter:[self splitLineCenter:CommentTypeFlower]];
    
    //update flower | save
    line = [self splitLineWithType:CommentTypeSave];
    [line setCenter:[self splitLineCenter:CommentTypeSave]];
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

- (void)setViewInfo:(PBOpus *)opus
{
    self.opus = opus;
    [self updateTimes:opus];
    [self updateSplitLines];
}


- (void)updateTimes:(PBOpus *)opus
{
    [self updateButtonWithType:CommentTypeComment
                         times:[opus feedTimesWithFeedTimesType:PBFeedTimesTypeFeedTimesTypeComment]
                        format:NSLS(@"kCommentTimes")];
    if (![opus isContestOpus]) {
        [self updateButtonWithType:CommentTypeGuess
                             times:[opus feedTimesWithFeedTimesType:PBFeedTimesTypeFeedTimesTypeGuess]
                            format:NSLS(@"kGuessTimes")];
    }else{
        UIButton *button = [self buttonWithType:CommentTypeGuess];
        UIButton *prev = [self previousButtonWithType:CommentTypeGuess];
        button.hidden = YES;
        button.frame = prev.frame;
    }
    
    [self updateButtonWithType:CommentTypeFlower
                         times:[opus feedTimesWithFeedTimesType:PBFeedTimesTypeFeedTimesTypeFlower]
                        format:NSLS(@"kFlowerTimes")];
    
    [self updateButtonWithType:CommentTypeSave
                         times:[opus feedTimesWithFeedTimesType:PBFeedTimesTypeFeedTimesTypeSave]
                        format:NSLS(@"kCollectTimes")];

}

@end

