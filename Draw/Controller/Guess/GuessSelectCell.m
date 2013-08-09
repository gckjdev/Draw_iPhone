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

@interface GuessSelectCell()
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

- (void)setCellInfo:(NSArray *)opuses{
    
    self.opuses = opuses;
    [self reloadView];
}

- (IBAction)clickOpusButton:(UIButton *)button {
    
    if ([delegate respondsToSelector:@selector(didClickOpusWithIndex:)]) {
        
        int index = self.indexPath.row * MAX_COUNT_OPUS + button.tag - OPUS_BUTTON_OFFSET;
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
    }
    
    for (; index < 20; index ++) {
        [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:@"round_dot_no@2x.png"] forState:UIControlStateNormal];
        [[self opusButtonWithIndex:index].layer removeAllAnimations];
    }
}

- (void)setCurrentGuessIndex:(int)index{
    int tag = index - indexPath.row * MAX_COUNT_OPUS + OPUS_BUTTON_OFFSET;
    if (tag < OPUS_BUTTON_OFFSET && tag > OPUS_BUTTON_OFFSET + MAX_COUNT_OPUS) {
        return;
    }
    
    for (int index = OPUS_BUTTON_OFFSET; index < OPUS_BUTTON_OFFSET + MAX_COUNT_OPUS; index ++) {
        UIButton *button = (UIButton *)[self viewWithTag:tag];
        [button.layer removeAllAnimations];
    }
    
    UIButton *button = (UIButton *)[self viewWithTag:tag];
    [button.layer addAnimation:[AnimationManager scaleTo:CATransform3DMakeScale(1.2, 1.2, 1.2) duration:0.5 scaleTo:CATransform3DMakeScale(0.8, 0.8, 0.8) duration:0.5 repeatCount:MAXFLOAT] forKey:nil];

}

- (IBAction)clickAwardButton:(id)sender {
    

}

@end
