//
//  CommonGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "CommonGuessController.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CommonDialog.h"
#import "CommonMessageCenter.h"
#import "LevelService.h"
#import "DrawSoundManager.h"
#import "OpusService.h"

@interface CommonGuessController ()

@property (retain, nonatomic) NSMutableArray *guessWords;

@end

@implementation CommonGuessController

- (void)dealloc {
    [_guessWords release];
    [_wordInputView release];
    [_opus release];
    [super dealloc];
}

- (id)initWithOpus:(Opus *)opus{
    
    if (self = [super init]) {
        
        self.opus = opus;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _wordInputView.answerImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.candidateImage = [UIImage imageNamed:@"wood_button@2x.png"];
//    _wordInputView.answer = _opus.pbOpus.name;
    _wordInputView.answer = @"草泥马";

    _wordInputView.delegate = self;
    
    // TODO: Set candidate here
    [_wordInputView setCandidates:@"是克拉草建设的离开泥法国就阿拉山马口" column:9];
    
    [_wordInputView setClickSound:[DrawSoundManager defaultManager].clickWordSound];
    [_wordInputView setWrongSound:[DrawSoundManager defaultManager].guessWrongSound];
    [_wordInputView setCorrectSound:[DrawSoundManager defaultManager].guessCorrectSound];

    
    self.guessWords = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    
    [self setWordInputView:nil];
    [super viewDidUnload];
}

- (IBAction)clickRunAwayButton:(id)sender {
    
    [[OpusService defaultService] submitGuessWords:_guessWords
                                              opus:_opus
                                         isCorrect:NO
                                             score:3
                                          delegate:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect{

    [_guessWords addObject:word];
    
    if (isCorrect) {
        [self didGuessCorrect:word];
    }else{
        [self didGuessWrong:word];
    }
}

- (void)didGuessCorrect:(NSString *)word{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessCorrect") delayTime:1 isHappy:YES];
}

- (void)didGuessWrong:(NSString *)word{
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGuessWrong") delayTime:1 isHappy:NO];
}

@end
