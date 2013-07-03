//
//  CommonActionHeader.m
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import "CommonActionHeader.h"
#import "UIButton+Extend.h"
#import "PBOpus+Extend.h"

//#define MIN_WIDTH 40
//#define GAP 4
//#define CELL_HEIGHT 25
//#define FONT [UIFont systemFontOfSize:11]
//
//@implementation CommonActionHeader
//
//+ (NSString*)getHeaderIdentifier
//{
//    return @"CommonActionHeader";
//}
//
//+ (CGFloat)getHeaderHeight
//{
//    return CELL_HEIGHT;
//}
//
//- (void)clickActionButton:(UIButton *)button
//{
//    if (button.tag != PBOpusActionTypeOpusActionTypeSave) {
//        
//        for (UIView *view in [self subviews]) {
//            
//            if ([view isKindOfClass:[UIButton class]]) {
//                UIButton *button = (UIButton *)view;
//                [button setSelected:NO];
//            }
//        }
//        
//        [button setSelected:YES];
//    }
//    
//    if ([_delegate respondsToSelector:@selector(didClickActionButton:)]) {
//        [_delegate didClickActionButton:button.tag];
//    }
//}
//
//- (void)setPBOpus:(PBOpus *)opus selectedActionType:(PBOpusActionType)type{
//    
//    [self removeAllSubviews];
//
//    CGFloat originX = 2 * GAP;
//
//    for (PBActionTimes *actionTimes in opus.actionTimesList) {
//        
//        CGRect rect = CGRectMake(originX, 3, MIN_WIDTH, CELL_HEIGHT);
//        NSString *title = [NSString stringWithFormat:@"%@ (%d)", actionTimes.name, actionTimes.value];
//        UIButton *button = [self buttonWithFrame:rect Title:title tag:actionTimes.type];
//        [button wrapTitle];
//        if (actionTimes.type == type) {
//            button.selected = YES;
//        }else{
//            button.selected = NO;
//        }
//        [self addSubview:button];
//        originX += (button.bounds.size.width + GAP);
//        UIView *seperator = [self seperatorWithOriginX:originX];
//        [self addSubview:seperator];
//        originX += (GAP + 1);
//    }
//}
//
//- (UIButton *)buttonWithFrame:(CGRect)frame
//                        Title:(NSString *)title
//                          tag:(int)tag{
//    
//    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
//    [button setTitle:title forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
//    button.titleLabel.font = FONT;
//
//    [button setTag:tag];
//    [button addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
//    return button;
//}
//
//- (UIView *)seperatorWithOriginX:(float)originX{
//    
//    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(originX, 3, 1, 18)] autorelease];
//    [view setBackgroundColor:[UIColor grayColor]];
//    return view;
//}
//
//
//@end


//
//  CommentHeaderView.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonActionHeader.h"

@interface CommonActionHeader()
@property (retain, nonatomic) PBOpus *opus;

@end

@implementation CommonActionHeader

- (void)dealloc
{
    [_opus release];
    [super dealloc];
}

#define CHANGE_TIMES 100

+ (NSString*)getHeaderIdentifier
{
    return @"CommonActionHeader";
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
    button.frame = CGRectMake(x, 0, width, [CommonActionHeader getHeaderHeight]);
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
    
    
    return CGPointMake(x, [CommonActionHeader getHeaderHeight] *0.5);
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

