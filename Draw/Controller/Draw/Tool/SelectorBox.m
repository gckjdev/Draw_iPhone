//
//  SelectorBox.m
//  Draw
//
//  Created by gamy on 13-7-9.
//
//

#import "SelectorBox.h"
#import "ShareImageManager.h"

@interface SelectorBox()

@property(nonatomic, retain) UIButton *closeButton;
@property(nonatomic, retain) UIImageView *closeButtonBG;

@end

@implementation SelectorBox



- (void)updateViews
{
    
}




- (void)dealloc
{
    PPDebug(@"<SelectorBox> dealloc");
    PPRelease(_closeButton);
    PPRelease(_closeButtonBG);
    [super dealloc];
}

+ (id)selectorBoxWithDelegate:(id<SelectorBoxDelegate>)delegate
{
    NSUInteger index = ISIPAD ? 1 : 0;
    SelectorBox *box = [UIView createViewWithXibIdentifier:@"SelectorBox" ofViewIndex:index];
    box.delegate = delegate;
    [box updateViews];
    return box;
}

#define TAG_PATH 100
#define TAG_POLYGON 101
#define TAG_ELLIPSE 102
#define TAG_RECTRANGLE 103


- (ClipType)clipTypeForTag:(NSInteger)tag
{
#ifndef JUDGE_TAG
#define JUDGE_TAG(tagValue, typeValue) \
    if (tag == tagValue)  {\
        return typeValue; }
#endif
    
    JUDGE_TAG(TAG_PATH, ClipTypeSmoothPath)
    JUDGE_TAG(TAG_POLYGON, ClipTypePolygon)
    JUDGE_TAG(TAG_ELLIPSE, ClipTypeEllipse)
    JUDGE_TAG(TAG_RECTRANGLE, ClipTypeRectangle)
  
    return ClipTypeNo;
}

- (IBAction)clickSelector:(UIButton *)sender {
    
    ClipType clipType = [self clipTypeForTag:sender.tag];
    if (_delegate && [_delegate respondsToSelector:@selector(selectorBox:didSelectClipType:)]) {
        [_delegate selectorBox:self didSelectClipType:clipType];
    }
}


- (IBAction)clickHelp:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickHelpAtSelectorBox:)]) {
        [_delegate didClickHelpAtSelectorBox:self];
    }
}

@end
