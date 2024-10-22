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
#import "SoundPlayer.h"
#import "AudioManager.h"

#define OPUS_BUTTON_OFFSET 100
#define MAX_COUNT_OPUS 20

@interface GuessSelectCell()
//@property (retain, nonatomic) NSArray *opuses;
@property (retain, nonatomic) NSArray *guesseds;
@end


@implementation GuessSelectCell

- (void)dealloc{
    
//    [_opuses release];
    [_awardButton release];
    [_guesseds release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    return @"GuessSelectCell";
}

+ (CGFloat)getCellHeight{
    return 408 * (ISIPAD ? 2.18 : 1);
}

- (void)setCellInfo:(NSArray *)guesseds{

//    self.opuses = opuses;
    self.guesseds = guesseds;
    
    [self reloadView];
}

- (IBAction)clickOpusButton:(UIButton *)button {
    
    [[AudioManager defaultManager] playSoundByName:SOUND_EFFECT_BUTTON_DOWN];
    
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
    for (; index < [_guesseds count]; index ++ ) {
        NSNumber *isGuessed = [_guesseds objectAtIndex:index];
        if (isGuessed.boolValue == YES) {
            [[self opusButtonWithIndex:index] setBackgroundImage:[UIImage imageNamedFixed:@"shoes@2x.png"] forState:UIControlStateNormal];
        }else{
            NSString *name = [NSString stringWithFormat:@"round_dot_%d@2x.png", index + 1];
            [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        }
    }
    
    for (; index < 20; index ++) {
        [[self opusButtonWithIndex:index] setImage:[UIImage imageNamed:@"round_dot_no@2x.png"] forState:UIControlStateNormal];
    }
}

- (void)setCurrentGuessIndex:(int)index{
    int tag = index - indexPath.row * MAX_COUNT_OPUS + OPUS_BUTTON_OFFSET;
    if (tag < OPUS_BUTTON_OFFSET || tag > (OPUS_BUTTON_OFFSET + MAX_COUNT_OPUS)) {
        return;
    }
    
    for (int index = OPUS_BUTTON_OFFSET; index < (OPUS_BUTTON_OFFSET + MAX_COUNT_OPUS); index ++) {
        UIButton *button = (UIButton *)[self viewWithTag:tag];
        [button.layer removeAllAnimations];
    }
    
    UIButton *button = (UIButton *)[self viewWithTag:tag];
    

    [button.layer addAnimation:[AnimationManager scaleTo:CATransform3DMakeScale(1.2, 1.2, 1.2) duration:0.5 scaleTo:CATransform3DMakeScale(0.8, 0.8, 0.8) duration:0.5 repeatCount:MAXFLOAT] forKey:nil];
}

- (void)setNotGuessFlash{
    
    for (int index = 0; index < [_guesseds count]; index ++) {
        UIButton *button = (UIButton *)[self viewWithTag:(index + OPUS_BUTTON_OFFSET)];
        [button.layer removeAllAnimations];
        
        NSNumber *isGuessed = [_guesseds objectAtIndex:index];
        if (!isGuessed.boolValue) {
            
            [button.layer addAnimation:[AnimationManager scaleTo:CATransform3DMakeScale(1.2, 1.2, 1.2) duration:0.5 scaleTo:CATransform3DMakeScale(0.8, 0.8, 0.8) duration:0.5 repeatCount:MAXFLOAT] forKey:nil];
        }
    }
}

- (void)setNothingFlash{
    
    for (int index = 0; index < MAX_COUNT_OPUS; index ++) {
        UIButton *button = (UIButton *)[self viewWithTag:(index + OPUS_BUTTON_OFFSET)];
        [button.layer removeAllAnimations];
    }
}

- (IBAction)clickAwardButton:(id)sender {
    

}

@end
