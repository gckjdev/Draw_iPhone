//
//  DrawGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "DrawGuessController.h"
#import "WordManager.h"

@interface DrawGuessController ()

@end

@implementation DrawGuessController

- (void)dealloc {
    [_titleView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_titleView setTitle:NSLS(@"kGuess")];
    [_titleView setTarget:self];
    
    // Set candidates
    NSString *candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:self.opus.pbOpus.name count:27];
    [self.wordInputView setCandidates:candidates column:9];
    
    [self.wordInputView setSeperatorYOffset:-4];
    [self.wordInputView setCandidateYOffset:-4];
    [self.wordInputView  setAnswerViewXOffset:8];
    
    [self.wordInputView setCandidateColor:[UIColor whiteColor]];

}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [super viewDidUnload];
}
@end
