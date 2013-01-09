//
//  WordSelectCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-3.
//
//

#import "WordSelectCell.h"
#import "AutoCreateViewByXib.h"
#import "DeviceDetection.h"

#define SMALL_FONT [UIFont systemFontOfSize:([DeviceDetection isIPAD] ? 28 : 14)]
#define LAG_FONT [UIFont systemFontOfSize:([DeviceDetection isIPAD] ? 40 : 20)]

#define WORD_BUTTON_TAG_OFFSET 200
#define COIN_IMAGE_VIEW_TAG_OFFSET 210
#define WORD_LABEL_TAG_OFFSET 220
#define WORD_SCORE_LABEL_TAG_OFFSET 230

#define WORD_MAX_COUNT 3

@interface WordSelectCell()

@property (retain, nonatomic, readwrite) NSArray *words;

@end

@implementation WordSelectCell

AUTO_CREATE_VIEW_BY_XIB(WordSelectCell)

- (void)dealloc {
    [_words release];
    
    [super dealloc];
}

+ (WordSelectCell *)createViewWithFrame:(CGRect)frame
{
    WordSelectCell *view = [self createView];
    view.frame = frame;
    return view;
}

- (void)setWord:(Word *)word index:(int)index
{
    if (word == nil) {
        [self wordLabel:index].text = @"";
        [self coinImageView:index].hidden = YES;
        [self wordScoreLabel:index].text = @"";
        return;
    }

    [[self wordLabel:index] setFont:([word length] > 3 ? SMALL_FONT : LAG_FONT)];
    [[self wordScoreLabel:index] setFont:SMALL_FONT];
    
    [self wordLabel:index].text = word.text;
    [self coinImageView:index].hidden = NO;
    [self wordScoreLabel:index].text = [NSString stringWithFormat:@"x %d", word.score];
    [[self wordButton:index] addTarget:self action:@selector(clickWordBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setWords:(NSArray *)words
{
    [_words release];
    _words = nil;
    _words = [words retain];
    
    int index = 0;
    for (; index < [words count] && index < WORD_MAX_COUNT; index ++) {
        [self setWord:[words objectAtIndex:index] index:index];
    }
    
    for (; index < WORD_MAX_COUNT; index ++) {
        [self setWord:nil index:index];
    }
}


- (void)clickWordBtn:(id)sender {
    if (![sender isKindOfClass:[UIButton class]]) {
        return;
    }
    
    int index = ((UIButton *)sender).tag - WORD_BUTTON_TAG_OFFSET;
    
    if (index < 0 || index >= [_words count]) {
        return;
    }
    
    Word *word = [_words objectAtIndex:index];

    if([_delegate respondsToSelector:@selector(didSelectWord:)]){
        [_delegate didSelectWord:word];
    }
}

- (UIButton *)wordButton:(int)index
{
    if (index >= 0 && index <=2) {
        UIView *view  = [self viewWithTag:(WORD_BUTTON_TAG_OFFSET + index)];
        return [view isKindOfClass:[UIButton class]] ? (UIButton *)view : nil;
    }else{
        PPDebug(@"assert( index >= 0 && index <= 2);");
        return nil;
    }
}

- (UIImageView *)coinImageView:(int)index
{
    if (index >= 0 && index <=2) {
        UIView *view  = [self viewWithTag:(COIN_IMAGE_VIEW_TAG_OFFSET + index)];
        return [view isKindOfClass:[UIImageView class]] ? (UIImageView *)view : nil;
    }else{
        PPDebug(@"assert( index >= 0 && index <= 2);");
        return nil;
    }
}

- (UILabel *)wordLabel:(int)index
{
    if (index >= 0 && index <=2) {
        UIView *view  = [self viewWithTag:(WORD_LABEL_TAG_OFFSET + index)];
        return [view isKindOfClass:[UILabel class]] ? (UILabel *)view : nil;
    }else{
        PPDebug(@"assert( index >= 0 && index <= 2);");
        return nil;
    }
}

- (UILabel *)wordScoreLabel:(int)index
{
    if (index >= 0 && index <=2) {
        UIView *view  = [self viewWithTag:(WORD_SCORE_LABEL_TAG_OFFSET + index)];
        return [view isKindOfClass:[UILabel class]] ? (UILabel *)view : nil;
    }else{
        PPDebug(@"assert( index >= 0 && index <= 2);");
        return nil;
    }
}

@end
