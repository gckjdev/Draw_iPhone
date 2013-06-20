//
//  SingGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "SingGuessController.h"

@interface SingGuessController ()

@end

@implementation SingGuessController

- (void)dealloc {
    [_wordInputView release];
    [_pbOpus release];
    [super dealloc];
}

- (id)initWithPBOpus:(PBOpus *)pbOpus{
    
    if (self = [super init]) {
        
        self.pbOpus = pbOpus;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _wordInputView.answerImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.candidateImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.answer = _pbOpus.name;
    [_wordInputView setCandidates:@"是克拉草建设的离开泥法国就阿拉山马口" column:9];
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

@end
