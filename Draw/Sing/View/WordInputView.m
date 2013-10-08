//
//  WordInputView.m
//  Draw
//
//  Created by 王 小涛 on 13-6-18.
//
//

#import "WordInputView.h"
#import "AudioManager.h"
#import "HPThemeManager.h"
#import "UIImageUtil.h"
#import "WordManager.h"

#define BUTTON_WIDTH (ISIPAD ? 70 : 30)
#define BUTTON_HEIGHT BUTTON_WIDTH
#define BUTTON_WIDTH_GAP (ISIPAD ? 12 : 4)
#define BUTTON_HEIGHT_GAP (ISIPAD ? 8 : 4)

#define DEFAULT_COLOR [UIColor whiteColor]

#define FONT [UIFont systemFontOfSize:(ISIPAD ? 30 : 15)]

#define BUTTON_TAG_OFFSET 1000

#define BOMB_CHAR ' '

#define MAX_CANDIDATE_COUNT 50

#define TRANSFORM_SCALE CGAffineTransformMakeScale(1.2, 1.2)


@interface WordInputView(){
    int _column;
    int _row;
    NSMutableArray *_guessWords;
}

// 候选字
@property (copy, nonatomic) NSString *candidates;

@property (retain, nonatomic) UIView *answerView;
@property (retain, nonatomic) UIImageView *sepertorImageView;
@property (retain, nonatomic) UIView *candidateView;
@property (assign, nonatomic) CGSize candidateSize;
@property (assign, nonatomic) CGSize answerSize;

@property (assign, nonatomic) CGFloat wGap;

@property (retain, nonatomic) UIImage *candidateImage;
@property (retain, nonatomic) UIImage *answerImage;
@property (copy, nonatomic) NSString *clickSound;
@property (copy, nonatomic) NSString *wrongSound;
@property (copy, nonatomic) NSString *correctSound;

@property (retain, nonatomic) UIColor *candidateColor;
@property (retain, nonatomic) UIColor *answerColor;

@end

@implementation WordInputView

- (void)dealloc{
    [_answer release];
    [_sepertorImageView release];
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
    [_guessWords release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
                
        self.candidateSize = self.answerSize = CGSizeMake(BUTTON_WIDTH, BUTTON_HEIGHT);
        
        CGRect frame1 = CGRectMake(0, 0, self.frame.size.width, _answerSize.width);
        self.answerView = [[[UIView alloc] initWithFrame:frame1] autorelease];
        
        UIImage *seperator = UIThemeImageNamed(@"word_input_seperator@2x.png");
        CGFloat originY = CGRectGetMaxY(_answerView.frame) - BUTTON_HEIGHT_GAP * 2;

        if (seperator != nil) {
            
            CGFloat width = ISIPAD ? seperator.size.width * 2 : seperator.size.width;
            CGFloat height = ISIPAD ? seperator.size.height * 2 : seperator.size.height;
            if (width > self.bounds.size.width) {
                width = self.bounds.size.width;
            }
            
            CGRect frame2 = CGRectMake(0, originY, width, height);

            self.sepertorImageView = [[[UIImageView alloc] initWithFrame:frame2] autorelease];
            _sepertorImageView.image = seperator;
            [_sepertorImageView updateCenterX:_answerView.center.x];
            [_sepertorImageView updateOriginY:originY];
        }
        
        originY = CGRectGetMaxY(_sepertorImageView.frame) + BUTTON_HEIGHT_GAP * 2;
        CGRect frame3 = CGRectMake(0, originY, self.frame.size.width, self.frame.size.height - originY);
        self.candidateView = [[[UIView alloc] initWithFrame:frame3] autorelease];
        
        [self addSubview:_answerView];
        [self addSubview:_sepertorImageView];
        [self addSubview:_candidateView];
        
        [self sendSubviewToBack:_sepertorImageView];
        
        self.candidateColor = self.answerColor = DEFAULT_COLOR;
        self.alignment = WordInputViewStyleAlignmentLeft;
        
        
        // Set appearance of wordInputView
        self.answerImage = ALL_ROUND_CORNER_IMAGE_FROM_COLOR(COLOR255(62, 62, 62, 0.5*255));     //UIThemeImageNamed(@"word_input_answer@2x.png");
        self.candidateImage = ALL_ROUND_CORNER_IMAGE_FROM_COLOR(COLOR_ORANGE); // UIThemeImageNamed(@"word_input_candidate@2x.png");
        
        // Set sound.
        self.clickSound = @"button_down.wav";
        self.wrongSound = @"oowrong.mp3";
        self.correctSound = @"correct.mp3";
        _guessWords = [[NSMutableArray alloc] init];
        
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
    _answer = [[answer uppercaseString] copy];
    

    [self retsetAnswerView];
}

- (void)setAlignment:(WordInputViewAlignment)alignment{
    
    _alignment = alignment;
    [self relayout];
}

- (void)setAnswerViewXOffset:(CGFloat)XOffset{
    
    _alignment = WordInputViewStyleAlignmentCustom;
    _wGap = XOffset;
    [self relayout];
}

- (void)setAnswerViewYOffset:(CGFloat)YOffset{
    
    [_answerView updateOriginY:YOffset];
}

- (void)setSeperatorYOffset:(CGFloat)YOffset{
    
    [_sepertorImageView updateOriginY:(_sepertorImageView.frame.origin.y + YOffset)];
}

- (void)setCandidateYOffset:(CGFloat)YOffset{
    
    [_candidateView updateOriginY:(_candidateView.frame.origin.y + YOffset)];
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
        NSString *ch = [self getButtonTitle:button];

        if (ch == nil) {
            return button;
        }
    }
    
    return nil;
}


- (void)setCandidates:(NSString *)candidates
                        column:(int)column{
    candidates = [candidates uppercaseString];
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
    
    NSRange range = [_candidates rangeOfString:[NSString stringWithFormat:@"%c", BOMB_CHAR]];
    BOOL bomb = (range.location != NSNotFound);
    
    for (int index = 0; index < [_candidates length]; index++) {
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        float originX = (index%_column) * (width + widthGap);
        float originY = (index/_column) * (height + heigtGap);
        
        CGRect frame = CGRectMake(originX, originY, width, height);
        UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
        [self setButton:button title:ch];
        button.titleLabel.font = FONT;
        [button setTitleColor:_candidateColor forState:UIControlStateNormal];
        
        if ([ch characterAtIndex:0] == BOMB_CHAR) {
            button.enabled = NO;
        }
        button.tag = BUTTON_TAG_OFFSET + index;
        [button addTarget:self action:@selector(candidateButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(candidateButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(candidateButtonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];

        [button setBackgroundImage:_candidateImage forState:UIControlStateNormal];
        
        if (bomb) {
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
            [_candidateView addSubview:button];
        }else{
            [self performSelector:@selector(addCandidateButton:) withObject:button afterDelay:(index * 0.1)];
        }
    }
    
    width = width * _column  + BUTTON_WIDTH_GAP * (_column - 1);
    height = height * _row + BUTTON_HEIGHT_GAP * (_row - 1);
    
    [_candidateView updateWidth:width];
    [_candidateView updateHeight:height];
    
    [self relayout];
    [self setBottomAlignment];
}

- (void)addCandidateButton:(UIButton *)button{

    [_candidateView addSubview:button];
    
    float duration = 0.25;
    button.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:duration animations:^{
        button.transform = TRANSFORM_SCALE;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            button.transform = CGAffineTransformIdentity;
        }];
    }];
}

- (void)candidateButtonTouchUpInside:(UIButton *)button{
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    
    NSString *ch = [self getButtonTitle:button];

    PPDebug(@"click candidate character: %@", ch);
    
    if (ch == nil) {
        return;
    }
    
    UIButton *answerButton = [self firstNilAnswerButton];
    if (answerButton == nil) {
        return;
    }
    
    [self setButton:button title:nil];
    button.enabled = NO;
    
    [[AudioManager defaultManager] playSoundByName:_clickSound];
    
    CGPoint startPoint = [_candidateView convertPoint:button.center toView:self];
    CGPoint endPoint = [_answerView convertPoint:answerButton.center toView:self];
    
    UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moveButton.frame = button.bounds;
    moveButton.center = startPoint;
    [self setButton:moveButton title:ch];
    moveButton.titleLabel.font = FONT;
    [moveButton setTitleColor:[button titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[button backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    [self addSubview:moveButton];

    [self setButton:answerButton title:@""];

    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        moveButton.center = endPoint;
    } completion:^(BOOL finished) {
        [moveButton removeFromSuperview];
        [self setButton:answerButton title:ch];
        [answerButton setEnabled:YES];
        
        [self detectWord];
    }];    
}

- (void)setButton:(UIButton *)button title:(NSString *)title{
    
    NSString *ltitle = [LocaleUtils isTraditionalChinese] ? [WordManager changeToTraditionalChinese:title] : title;
    
    [button setTitle:ltitle forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
}

- (NSString *)getButtonTitle:(UIButton *)button{
    
    return [[[button titleForState:UIControlStateSelected] copy] autorelease];
}

- (void)candidateButtonTouchUpOutSide:(UIButton *)button{
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
}

- (void)candidateButtonTouchDown:(UIButton *)button{
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = TRANSFORM_SCALE;
    }];
}

- (void)detectWord{
    
    NSString *word = @"";
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        NSString *ch = [self getButtonTitle:button];
        
        if (ch != nil) {
            word = [word stringByAppendingString:ch];
        }
    }
    
    if ([word length] < [_answer length]) {
        return;
    }
    
    BOOL isCorrect = [[word uppercaseString] isEqualToString:[_answer uppercaseString]];
    if (isCorrect) {
        [[AudioManager defaultManager] playSoundByName:_correctSound];
        [self changeAnswerButtonsTitleColor:COLOR_GREEN];
        PPDebug(@"You get it: %@", word);
    }else{
        [[AudioManager defaultManager] playSoundByName:_wrongSound];
        [self changeAnswerButtonsTitleColor:COLOR_RED];
        [self shakeAnswerButtons];
        PPDebug(@"Wrong word: %@", word);
    }
    [_guessWords addObject:word];
    if ([_delegate respondsToSelector:@selector(wordInputView:didGetWord:isCorrect:)]) {
        [_delegate wordInputView:self didGetWord:word isCorrect:isCorrect];
    }
}

- (void)changeButtonColor:(NSArray *)array//:(UIButton *)button Color:(UIColor *)color
{
    [array[0] setTitleColor:array[1] forState:UIControlStateNormal];
}


- (void)changeAnswerButtonsTitleColor:(UIColor *)color{
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        UIColor *oldColor = [button titleColorForState:UIControlStateNormal];
        for (NSInteger x = 0; x < 7; x++) {
            UIColor *cl = (x % 2 == 0) ? color : oldColor;
            [self performSelector:@selector(changeButtonColor:) withObject:@[button, cl] afterDelay:(x * 0.2)];
        }
    }
}

- (void)resetAnswerButtonsTitleColor{
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [button setTitleColor:_answerColor forState:UIControlStateNormal];
    }
}

- (void)shakeAnswerButtons{
    
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:-M_PI/24];
    shake.toValue   = [NSNumber numberWithFloat:+M_PI/24];
    shake.duration = 0.1;//摆动一次耗时
    shake.autoreverses = YES;
    shake.repeatCount = 6;//摆动次数
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [button.layer addAnimation:shake forKey:nil];
    }
}


- (void)answerButtonTouchUpInside:(UIButton *)button{
    
    [self resetAnswerButtonsTitleColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
    
    NSString *ch = [self getButtonTitle:button];

    PPDebug(@"click answer character: %@", ch);
    
    if (ch == nil) {
        return;
    }
    
    UIButton *candidateButton = [self firstNilCandidateButtonWithCharacter:ch];
    if (candidateButton == nil) {
        return;
    }

    [self setButton:button title:nil];
    button.enabled = NO;
        
    CGPoint startPoint = [_answerView convertPoint:button.center toView:self];
    CGPoint endPoint = [_candidateView convertPoint:candidateButton.center toView:self];

    UIButton *moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self setButton:moveButton title:ch];
    moveButton.titleLabel.font = FONT;
    [moveButton setTitleColor:[button titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
    [moveButton setBackgroundImage:[button backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
    moveButton.frame = button.bounds;
    moveButton.center = startPoint;
    [self addSubview:moveButton];
    
    [self setButton:candidateButton title:@""];
    
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        moveButton.center = endPoint;
    } completion:^(BOOL finished) {
        [moveButton removeFromSuperview];
        [self setButton:candidateButton title:ch];
        candidateButton.enabled = YES;
    }];

}

- (void)answerButtonTouchUpOutSide:(UIButton *)button{

    [UIView animateWithDuration:0.3 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
}

- (void)answerButtonTouchDown:(UIButton *)button{
    
    [UIView animateWithDuration:0.3 animations:^{
        button.transform = TRANSFORM_SCALE;
    }];
}

- (UIButton *)firstNilCandidateButtonWithCharacter:(NSString *)character{
    
    UIButton *button = nil;
    
    for (int index = 0; index < [_candidates length]; index ++) {
        
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        if ([ch isEqualToString:character]) {
            
            button = [self candidateButtonWithIndex:index];
            
            // 找到character对应的button, 把character设置回去。
            if ([self getButtonTitle:button] == nil) {
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
        [self answerButtonTouchUpInside:button];
    }
}

- (void)clearAnswerView{
    
    for (int index = 0; index < [_answer length]; index ++) {
        UIButton *button = [self answerButtonWithIndex:index];
        [self setButton:button title:nil];
        button.enabled = NO;
    }
}

- (void)resetCandidateView{
    
    for (int index = 0; index < [_candidates length]; index ++) {
        
        NSString *ch = [_candidates substringWithRange:NSMakeRange(index, 1)];
        
        UIButton *button = [self candidateButtonWithIndex:index];
        [self setButton:button title:ch];
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
        [button addTarget:self action:@selector(answerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(answerButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(answerButtonTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];


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

- (void)setBottomAlignment{
    
    CGFloat bottomGap = 1.5 * BUTTON_HEIGHT_GAP;

    CGFloat  bottomY = CGRectGetMaxY(self.frame);
    
    CGFloat height =  CGRectGetMaxY(_candidateView.frame) - CGRectGetMinY(_answerView.frame) + bottomGap;
    [self updateHeight:height];
    
    CGFloat currentGap = self.frame.size.height - CGRectGetMaxY(_candidateView.frame);
    
    CGFloat delta = bottomGap - currentGap;
    
    [self setAnswerViewYOffset:-delta];
    [self setSeperatorYOffset:-delta];
    [self setCandidateYOffset:-delta];
    
    delta = CGRectGetMaxY(self.frame) - bottomY;
    self.frame = CGRectOffset(self.frame, 0, -delta);
    
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


- (NSArray *)guessedWords
{
    return _guessWords;
}

#define TAG_DISABLE_VIEW 20130905
- (void)setDisable:(BOOL)disable
{
    UIControl *control = (id)[self reuseViewWithTag:TAG_DISABLE_VIEW viewClass:[UIControl class] frame:self.bounds];
    control.userInteractionEnabled = disable;
}

@end
