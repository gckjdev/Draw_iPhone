//
//  CommonGuessController.h
//  Draw
//
//  Created by 王 小涛 on 13-6-19.
//
//

#import "PPViewController.h"
#import "WordInputView.h"
#import "Opus.h"
#import "PickToolView.h"

@interface CommonGuessController : PPViewController <WordInputViewDelegate, PickViewDelegate>

@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) Opus *opus;

- (id)initWithOpus:(Opus *)opus;
- (IBAction)clickToolBoxButton:(id)sender;

- (void)initPickToolView;

// Rewrite in sub-class
- (void)didGuessWrong:(NSString *)word;
- (void)didGuessCorrect:(NSString *)word;
- (void)runAway;

@end