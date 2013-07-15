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

#define IMAGE_VIEW_SIZE (ISIPAD ? 140 : 70)
#define CLOSE_VIEW_SIZE (ISIPAD ? 80 : 40)

#define CLOSE_BUTTON_TAG 123
#define CLOSE_BUTTON_BG_TAG 124
#define CLOSE_VIEW_X (ISIPAD ? (768-IMAGE_VIEW_SIZE-34) : (320-IMAGE_VIEW_SIZE-10))
#define CLOSE_VIEW_Y (ISIPAD ? 100 : 50)

- (void)removeCloseView
{
    [self.closeButton removeTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButtonBG removeFromSuperview];
    [self.closeButton removeFromSuperview];
    
    self.closeButtonBG = nil;
    self.closeButton = nil;
}

- (void)showCloseViewInView:(UIView *)view
{
    [self removeCloseView];
    
    
    UIView *_closeView = [UIView createViewWithXibIdentifier:@"SelectorBox"  ofViewIndex:2];
    
    if (ISIPAD) {
        _closeView.frame = CGRectMake(CLOSE_VIEW_X, CLOSE_VIEW_Y, IMAGE_VIEW_SIZE, IMAGE_VIEW_SIZE);
    }else{
        _closeView.frame = CGRectMake(CLOSE_VIEW_X, CLOSE_VIEW_Y, IMAGE_VIEW_SIZE, IMAGE_VIEW_SIZE);
    }
    self.closeButton = (id)[_closeView viewWithTag:CLOSE_BUTTON_TAG];
    self.closeButtonBG = (id)[_closeView viewWithTag:CLOSE_BUTTON_BG_TAG];
    
    [self.closeButton addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button = [self closeButton];
    CGFloat x = CLOSE_VIEW_X + CGRectGetMinX(button.frame);
    CGFloat y = CLOSE_VIEW_Y + CGRectGetMinY(button.frame);
    [button updateOriginX:x];
    [button updateOriginY:y];
    
    UIImageView *bg = [self closeButtonBG];
    x = CLOSE_VIEW_X + CGRectGetMinX(bg.frame);
    y = CLOSE_VIEW_Y + CGRectGetMinY(bg.frame);
    [bg updateOriginX:x];
    [bg updateOriginY:y];
    
    [view addSubview:button];
    [view addSubview:bg];
    
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

- (IBAction)clickCancel:(id)sender {
    [[self closeButton] removeFromSuperview];
    [[self closeButtonBG] removeFromSuperview];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didClickCancelAtSelectorBox:)]) {
        [_delegate didClickCancelAtSelectorBox:self];
    }
}

- (IBAction)clickHelp:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickHelpAtSelectorBox:)]) {
        [_delegate didClickHelpAtSelectorBox:self];
    }
}

@end
