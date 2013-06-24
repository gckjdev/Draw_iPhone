//
//  SingGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "SingGuessController.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CommonDialog.h"
#import "CommonMessageCenter.h"
#import "AudioManager.h"
#import "LevelService.h"
#import "DrawSoundManager.h"
#import "OpusService.h"

@interface SingGuessController ()

@property (retain, nonatomic) NSMutableArray *guessWords;

@end

@implementation SingGuessController

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
    _wordInputView.answer = _opus.pbOpus.name;
    _wordInputView.delegate = self;
    
    // TODO: Set candidate here
    [_wordInputView setCandidates:@"是克拉草建设的离开泥法国就阿拉山马口" column:9];
    
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
}

- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect{

    [_guessWords addObject:word];
    
    if (isCorrect) {
        
        // Jump to another controller
    }else{
        
        
    }
}

@end
