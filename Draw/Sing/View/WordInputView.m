//
//  WordInputView.m
//  Draw
//
//  Created by 王 小涛 on 13-6-18.
//
//

#import "WordInputView.h"
#import "AudioManager.h"

#define BUTTON_WIDTH (ISIPAD ? 65 : 30)
#define BUTTON_HEIGHT BUTTON_WIDTH
#define BUTTON_WIDTH_GAP (ISIPAD ? 9 : 4)
#define BUTTON_HEIGHT_GAP (ISIPAD ? 9 : 4)

#define DEFAULT_COLOR [UIColor blackColor]

#define FONT [UIFont systemFontOfSize:(ISIPAD ? 26 : 13)]

#define BUTTON_TAG_OFFSET 1000

#define BOMB_CHAR ' '
#define BOMB_CHAR_STRING [NSString stringWithCharacters:BOMB_CHAR length:1]

#define MAX_CANDIDATE_COUNT 50


@interface WordInputView(){
    int _column;
    int _row;
}

// 候选字
@property (copy, nonatomic) NSString *candidates;

@property (retain, nonatomic) UIView *candidateView;
@property (retain, nonatomic) UIView *answerView;
@property (assign, nonatomic) CGSize candidateSize;
@property (assign, nonatomic) CGSize answerSize;
@end

@implementation WordInputView

- (void)dealloc{
    
    [_answer release];
    [_candidates release];
    [_candidateView release];
    [_answerView release];
    [_candidateImage release];
    [_answerImage release];
    [_candidateColor release];
    [_answerColor release];
    [_clickSound release];
    [_wrongSound release];
    [_correctSound release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        
        self.candidateSize = self.answerSize = CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT);
        
        CGRect frame1 = CGRectMake(0, 0, self.frame.size.width, _answerSize.width);
        self.answerView = [[[UIView alloc] initWithFrame:frame1] autorelease];
        
        CGRect frame2 = CGRectMake(0, _answerSize.height + BUTTON_HEIGHT_GAP, self.frame.size.width, self.frame.size.height - (_answerSize.height + BUTTON_HEIGHT_GAP));
        self.candidateView = [[[UIView alloc] initWithFrame:frame2] autorelease];
        
        [self addSubview:_answerView];
        [self addSubview:_candidateView];
        
        self.candidateColor = self.answerColor = DEFAULT_COLOR;
        self.alignment = WordInputViewStyleAlignmentLeft;
    }
    
    return self;
}

- (void)setAnswer:(NSString *)answer{
    
    if ([answer length] < 1) {
        return;
    }
    
    if (_answer == answer) {
        return;
    }
    
    [_answer release];
    _answer = [answer copy];
    

    [self retsetAnswerView];
}

- (void)setAlignment:(WordInputViewAlignment)alignment{
    
    _alignment = alignment;
    [self relayout];
}

- (void)setWGap:(CGFloat)wGap{
    
    _alignment = WordInputViewStyleAlignmentCustom;
    _wGap = wGap;
    [self relayout];
}


- (void)setHGap:(CGFloat)hGap{
    
    [_candidateView updateOriginY:(_answerView.bounds.size.height + hGap)];
}

- (void)setCandidateImage:(UIImage *)candidateImage{
    
    [_candidateImage release];
    _candidateImage = [candidateImage retain];

    for (int index = 0; index < [_candidates length]; index ++) {
        UIButton *button = [self candidateButtonWithIndex:index];
        [button setBackgroundImage:candidateImage forState:UIControlStateNormal];
    }
}

- (void)setCandidateColor:(UIColor *)candidateColor{
    
    [_candidateColor release];
    _candidateColor = candidateColor;
    
    for (int index = 0; index < [_candidates length]; index ++) {
        UIButton *button = [self candidateButtonWithIndex:index];
        [button setTitleColor:candidateColor forState:UIControlStateNormal];
    }
}

- (void)setAnswerImage:(UIImage *)answerImage{
    
    [_answerImage release];
    _answerImage = [answerImage retain];
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [button setBackgroundImage:answerImage forState:UIControlStateNormal];
    }
}

- (void)setAnswerColor:(UIColor *)answerColor{
    
    [_answerColor release];
    _answerColor = answerColor;
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [button setTitleColor:answerColor forState:UIControlStateNormal];
    }
}

- (UIButton *)firstNilAnswerButton{
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        NSString *ch = [button titleForState:UIControlStateNormal];
        if (ch == nil) {
            return button;
        }
    }
    
    return nil;
}


- (void)setCandidates:(NSString *)candidates
                        column:(int)column{
    
    if ([_candidates isEqualToString:candidates] || column <= 0) {
        return;
    }
    
    [self clearAnswerView];
    [_candidateView removeAllSubviews];
    
    [_candidates release];
    _candidates = [candidates copy];
    
    _column = column;
    _row = ceilf([candidates length] / (float)column);
    
    [self reloadCandidates];
}


- (void)reloadCandidates{
    
    [_candidateView removeAllSubviews];
    
    float width = _candidateSize.width;
    float height = _candidateSize.height;
    float widthGap = BUTTON_WIDTH_GAP;
    float heigtGap = BUTTON_HEIGHT_GAP;
    
    for (int index = 0; index < [_candidates length]; index++) {
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        float originX = (index%_column) * (width + widthGap);
        float originY = (index/_column) * (height + heigtGap);
        
        CGRect frame = CGRectMake(originX, originY, width, height);
        UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
        [button setTitle:ch forState:UIControlStateNormal];
        button.titleLabel.font = FONT;
        [button setTitleColor:_candidateColor forState:UIControlStateNormal];
        if ([ch characterAtIndex:0] == BOMB_CHAR) {
            button.enabled = NO;
        }
        button.tag = BUTTON_TAG_OFFSET + index;
        [button addTarget:self action:@selector(clickCandidateButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:_candidateImage forState:UIControlStateNormal];
        [_candidateView addSubview:button];
    }
    
    width = width * _column  + BUTTON_WIDTH_GAP * (_column - 1);
    height = height * _row + BUTTON_HEIGHT_GAP * (_row - 1);
    
    [_candidateView updateWidth:width];
    [_candidateView updateHeight:height];
    
    [self relayout];
}

- (void)clickCandidateButton:(UIButton *)button{
    
    NSString *ch = [[[button titleForState:UIControlStateNormal] copy] autorelease];
    PPDebug(@"click candidate character: %@", ch);
    
    if (ch == nil) {
        return;
    }
    
    UIButton *answerButton = [self firstNilAnswerButton];
    if (answerButton == nil) {
        return;
    }
    
    [button setTitle:nil forState:UIControlStateNormal];
    button.enabled = NO;
    
    [[AudioManager defaultManager] playSoundByName:_clickSound];
    
    CGPoint startPoint = [_candidateView convertPoint:button.center toView:self];
    CGPoint endPoint = [_answerView convertPoint:answerButton.center toView:self];
    
    UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moveButton.frame = button.bounds;
    moveButton.center = startPoint;
    [moveButton setTitle:ch forState:UIControlStateNormal];
    moveButton.titleLabel.font = FONT;
    [moveButton setTitleColor:[button titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[button backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self addSubview:moveButton];

    [answerButton setTitle:@"" forState:UIControlStateNormal];

    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        moveButton.center = endPoint;
    } completion:^(BOOL finished) {
        [moveButton removeFromSuperview];
        [answerButton setTitle:ch forState:UIControlStateNormal];
        [answerButton setEnabled:YES];
        
        [self detectWord];
    }];    
}

- (void)detectWord{
    
    NSString *word = @"";
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        NSString *ch = [button titleForState:UIControlStateNormal];
        if (ch == nil) {
            return;
        }
        word = [word stringByAppendingString:ch];
    }
    
    BOOL isCorrect = [word isEqualToString:_answer];
    if (isCorrect) {
        [[AudioManager defaultManager] playSoundByName:_correctSound];
        PPDebug(@"You get it: %@", word);
    }else{
        [[AudioManager defaultManager] playSoundByName:_wrongSound];
        PPDebug(@"Wrong word: %@", word);
    }
    
    if ([_delegate respondsToSelector:@selector(wordInputView:didGetWord:isCorrect:)]) {
        [_delegate wordInputView:self didGetWord:word isCorrect:isCorrect];
    }
}

- (void)clickAnswerButton:(UIButton *)button{
    NSString *ch = [[[button titleForState:UIControlStateNormal] copy] autorelease];
    PPDebug(@"click answer character: %@", ch);
    
    if (ch == nil) {
        return;
    }
    
    UIButton *candidateButton = [self firstNilCandidateButtonWithCharacter:ch];
    if (candidateButton == nil) {
        return;
    }

    [button setTitle:nil forState:UIControlStateNormal];
    button.enabled = NO;
        
    CGPoint startPoint = [_answerView convertPoint:button.center toView:self];
    CGPoint endPoint = [_candidateView convertPoint:candidateButton.center toView:self];

    UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moveButton setTitle:ch forState:UIControlStateNormal];
    moveButton.titleLabel.font = FONT;
    [moveButton setTitleColor:[button titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[button backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    moveButton.frame = button.bounds;
    moveButton.center = startPoint;
    [self addSubview:moveButton];
    
    [candidateButton setTitle:@"" forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        moveButton.center = endPoint;
    } completion:^(BOOL finished) {
        [moveButton removeFromSuperview];
        [candidateButton setTitle:ch forState:UIControlStateNormal];
        candidateButton.enabled = YES;
    }];

}

- (UIButton *)firstNilCandidateButtonWithCharacter:(NSString *)character{
    
    UIButton *button = nil;
    
    for (int index = 0; index < [_candidates length]; index ++) {
        
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        if ([ch isEqualToString:character]) {
            
            button = [self candidateButtonWithIndex:index];
            
            // 找到character对应的button, 把character设置回去。
            if ([button titleForState:UIControlStateNormal] == nil) {
                return button;
            }
            
            continue;
        }
    }
    
    return nil;
}

- (UIButton *)candidateButtonWithIndex:(int)index{
    
    UIButton *button = (UIButton *)[_candidateView viewWithTag:(BUTTON_TAG_OFFSET + index)];
    return button;
}

- (UIButton *)answerButtonWithIndex:(int)index{
    
    UIButton *button = (UIButton *)[_answerView viewWithTag:(BUTTON_TAG_OFFSET + index)];
    return button;
}


- (void)reset{
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [self clickAnswerButton:button];
    }
}

- (void)clearAnswerView{
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [button setTitle:nil forState:UIControlStateNormal];
        button.enabled = NO;
    }
}

- (void)resetCandidateView{
    
    for (int index = 0; index < [_candidates length]; index ++) {
        
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        UIButton *button = [self candidateButtonWithIndex:index];
        [button setTitle:ch forState:UIControlStateNormal];
        button.enabled = YES;
    }
}

- (void)retsetAnswerView{
    
    [_answerView removeAllSubviews];
    
    float width = _answerSize.width;
    float height = _answerSize.height;
    
    for (int index = 0; index < [_answer length]; index ++) {
        
        float originX = (width + BUTTON_WIDTH_GAP) * index;
        
        UIButton *button = [[[UIButton alloc] initWithFrame:CGRectMake(originX, 0, width, height)] autorelease];
        [button setTitleColor:_answerColor forState:UIControlStateNormal];
        button.titleLabel.font = FONT;
        button.tag = BUTTON_TAG_OFFSET + index;
        button.enabled = NO;
        [button addTarget:self action:@selector(clickAnswerButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:_answerImage forState:UIControlStateNormal];
        [_answerView addSubview:button];
    }
    
    width = width * [_answer length] + BUTTON_WIDTH_GAP * ([_answer length] - 1);
    [_answerView updateWidth:width];
    [_answerView updateHeight:height];
    
    [self relayout];
}

- (void)relayout{
    
    switch (_alignment) {
        case WordInputViewStyleAlignmentLeft:
            [_candidateView updateCenterX:self.bounds.size.width/2];
            [_answerView updateOriginX:_candidateView.frame.origin.x];
            break;
            
        case WordInputViewStyleAlignmentCenter:
            [_candidateView updateCenterX:self.bounds.size.width/2];
            [_answerView updateCenterX:_candidateView.center.x];
            break;
            
        case WordInputViewStyleAlignmentRight:
            [_candidateView updateCenterX:self.bounds.size.width/2];
            [_answerView updateOriginX:(_candidateView.center.x + _candidateView.bounds.size.width/2 - _answerView.bounds.size.width)];
            break;
            
        case WordInputViewStyleAlignmentCustom:
            [_candidateView updateCenterX:self.bounds.size.width/2];
            [_answerView updateOriginX:(_candidateView.frame.origin.x + _wGap)];
            break;
            
        default:
            break;
    }
}

- (void)bomb:(int)count{
    
    int nonBombCharCount = [self nonBombCharCountInCandidates];
    int canBombCharCount = nonBombCharCount - [_answer length];
    
    if (canBombCharCount <= 0) {
        PPDebug(@"You cannot bomb any more!");
    }
    
    if (count > canBombCharCount) {
        count = canBombCharCount;
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (int index = 0; index < [_answer length]; index ++) {
        NSString *ch = [_answer substringWithRange:NSMakeRange(index, 1)];
        NSNumber *count = [dict objectForKey:ch];
        if (count) {
            count = @(count.intValue + 1);
        }else{
            count = @(1);
        }
        [dict setObject:count forKey:ch];
    }
    
    BOOL canBombIndexs[MAX_CANDIDATE_COUNT] = {NO};
    
    for (int i = 0; i < _candidates.length; ++ i) {
        NSString *ch = [_candidates substringWithRange:NSMakeRange(i, 1)];
        NSNumber *number = [dict objectForKey:ch];
        if (number == nil || number.integerValue == 0) {
            canBombIndexs[i] = YES;
        }else{
            canBombIndexs[i] = NO;
            number = @(number.intValue - 1);
            [dict setObject:number forKey:ch];
        }
    }
    [dict release];
    
    NSMutableString *s = [NSMutableString stringWithString:_candidates];
    NSInteger index = rand() % s.length;
    while (count > 0) {
        unichar ch = [s characterAtIndex:index];
        if (ch != BOMB_CHAR && canBombIndexs[index]) {
            count --;
            ch = BOMB_CHAR;
            NSString *rep = [NSString stringWithFormat:@"%c",ch];
            [s replaceCharactersInRange:NSMakeRange(index, 1) withString:rep];
            index = rand() % s.length;
        }else{
            index = (index + 1) % s.length;
        }
    }
    
    [self setCandidates:s column:_column];
}

- (void)bombHalf{
    
    [self bomb:([_candidates length]/2)];
}

- (int)nonBombCharCountInCandidates{
    
    int count = 0;
    for (int index = 0; index < [_candidates length]; index ++) {
        unichar ch = [_candidates characterAtIndex:index];
        if (ch != BOMB_CHAR) {
            count ++;
        }
    }
    return count;
}

@end
