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

@protocol CommonGuessControllerDelegate <NSObject>

- (void)didGuessCorrect;
- (void)didGuessWrong;


@end

@interface CommonGuessController : PPViewController <WordInputViewDelegate, PickViewDelegate>
@property (assign, nonatomic) id<CommonGuessControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;
@property (retain, nonatomic) IBOutlet UIButton *toolBoxButton;

@property (retain, nonatomic) Opus *opus;
@property (retain, nonatomic) NSMutableArray *guessWords;

- (id)initWithOpus:(Opus *)opus mode:(PBUserGuessMode)mode contestId:(NSString *)contestId;
- (IBAction)clickToolBoxButton:(id)sender;
- (IBAction)clickOpusButton:(id)sender;

- (void)submitWords;

// optional - implemented in your sub-class
- (void)didGuessWrong:(NSString *)word;
- (void)didGuessCorrect:(NSString *)word;
- (void)clickBack:(id)sender;

@end
