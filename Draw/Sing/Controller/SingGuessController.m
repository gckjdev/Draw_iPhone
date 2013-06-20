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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _wordInputView.answerImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.candidateImage = [UIImage imageNamed:@"wood_button@2x.png"];
    _wordInputView.answer = @"草泥马";
    [_wordInputView setCandidates:@"是克拉草建设的离开泥法国就阿拉山马口" column:9];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_wordInputView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWordInputView:nil];
    [super viewDidUnload];
}

- (IBAction)clickChangeButton:(id)sender {
    
    static BOOL flag;
    flag = !flag;
    if (flag) {
        [_wordInputView setCandidates:@"哈草斯科斯坦共泥和国的天下马无敌的没包含实例变量类别" column:9];
    }else{
        [_wordInputView setCandidates:@"是克拉草建设的离开泥法国就阿拉山马口" column:9];
    }
}

- (IBAction)clickResetButton:(id)sender {

    
    [_wordInputView reset];
}

- (IBAction)clickBombButton:(id)sender {
    
    [_wordInputView bomb:3];
}
- (IBAction)clickAlignmentButton:(id)sender {
    static int ali = 0;
    ali ++;
    [_wordInputView setAlignment:(ali % 3)];
}

- (IBAction)clickHGap:(id)sender {
    static int hgap = 0;
    hgap += 2;
    [_wordInputView setHGap:hgap];
}

- (IBAction)clickWGap:(id)sender {
    static int hgap = 0;
    hgap += 2;
    [_wordInputView setWGap:hgap];
}
@end
