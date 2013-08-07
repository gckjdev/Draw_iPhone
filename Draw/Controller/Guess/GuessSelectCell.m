//
//  GuessSelectCell.m
//  Draw
//
//  Created by 王 小涛 on 13-7-30.
//
//

#import "GuessSelectCell.h"
#import "Opus.pb.h"
#import "AnimationManager.h"

#define OPUS_BUTTON_OFFSET 100
#define MAX_COUNT_OPUS 20

@interface GuessSelectCell(){
    int _cellRowIndex;
    int _curGuessIndex;
}
@property (retain, nonatomic) NSArray *opuses;

@end


@implementation GuessSelectCell

- (void)dealloc{
    
    [_opuses release];
    [_awardButton release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    return @"GuessSelectCell";
}

+ (CGFloat)getCellHeight{
    return 408;
}

- (void)setCellInfo:(NSArray *)opuses
            cellRow:(int)cellRow
      curGuessIndex:(int)curGuessIndex{
    
    self.opuses = opuses;
    _cellRowIndex = cellRow;
    _curGuessIndex = curGuessIndex;
    [self reloadView];
}

- (IBAction)clickOpusButton:(UIButton *)button {
    
    if ([delegate respondsToSelector:@selector(didClickOpusWithIndex:)]) {
        
        int index = _cellRowIndex * MAX_COUNT_OPUS + button.tag - OPUS_BUTTON_OFFSET;
        [delegate didClickOpusWithIndex:index];
    }
}

- (UIButton *)opusButtonWithIndex:(int)index{
    
    return (UIButton *)[self viewWithTag:(index + OPUS_BUTTON_OFFSET)];
}

- (void)reloadView{
    
    int index = 0;
    for (; index < [_opuses count]; index ++ ) {
        PBOpus *pbOpus = [_opuses objectAtIndex:index];
        if (pbOpus.guessInfo.isCorrect) {
            [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:@"pine_tree@2x.png"] forState:UIControlStateNormal];
        }else{
            NSString *name = [NSString stringWithFormat:@"round_dot_%d@2x.png", index + 1];
            [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        }
        [[self opusButtonWithIndex:index].layer removeAllAnimations];

    }
    
    for (; index < 20; index ++) {
        [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:@"round_dot_no@2x.png"] forState:UIControlStateNormal];
        [[self opusButtonWithIndex:index].layer removeAllAnimations];
    }
    
    
    index = _curGuessIndex - (_cellRowIndex * MAX_COUNT_OPUS);
    if (index >= 0 && index < [_opuses count]) {
        CAAnimation *ani = [AnimationManager scaleTo:CATransform3DMakeScale(1.2, 1.2, 1.2) duration:1 scaleTo:CATransform3DMakeScale(0.8, 0.8, 0.8) duration:1 repeatCount:FLT_MAX];
        [[self opusButtonWithIndex:index].layer addAnimation:ani forKey:nil];
    }
}

- (IBAction)clickAwardButton:(id)sender {
    

}
@end
