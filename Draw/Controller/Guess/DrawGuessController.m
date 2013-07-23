//
//  DrawGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "DrawGuessController.h"
#import "CommonTitleView.h"
#import "WordManager.h"

@interface DrawGuessController ()

@end

@implementation DrawGuessController

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CommonTitleView *titleView = [CommonTitleView createWithTitle:NSLS(@"kGuess") delegate:self];
    [self.view addSubview:titleView];
    
    // Set candidates
    NSString *candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:self.opus.pbOpus.name count:27];
    [self.wordInputView setCandidates:candidates column:9];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}


@end
