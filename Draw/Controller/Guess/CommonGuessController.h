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
#import "GuessService.h"

@protocol CommonGuessControllerDelegate <NSObject>

- (void)didGuessCorrect:(Opus *)opus index:(int)index;
- (void)didGuessWrong:(Opus *)opus index:(int)index;


@end

@interface CommonGuessController : PPViewController <WordInputViewDelegate, PickViewDelegate, GuessServiceDelegate>
@property (assign, nonatomic) id<CommonGuessControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;
@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet UIButton *toolBoxButton;
@property (retain, nonatomic) IBOutlet UIButton *tipButton;

@property (assign, nonatomic) int index;
@property (retain, nonatomic) Opus *opus;
@property (retain, nonatomic) NSMutableArray *guessWords;

- (id)initWithOpus:(Opus *)opus mode:(PBUserGuessMode)mode contest:(PBGuessContest *)contest;
- (IBAction)clickToolBoxButton:(id)sender;
- (IBAction)clickOpusButton:(id)sender;
- (IBAction)clickTipButton:(id)sender;

// optional - implemented in your sub-class
- (void)didGuessWrong:(NSString *)word;
- (void)didGuessCorrect:(NSString *)word;
- (void)clickBack:(id)sender;

@end
