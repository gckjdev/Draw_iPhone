//
//  SingGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-24.
//
//

#import "SingGuessController.h"
#import "UIButtonExt.h"
#import "VoiceChanger.h"

@interface SingGuessController ()

@property (retain, nonatomic) VoiceChanger *player;

@end

@implementation SingGuessController

- (void)dealloc {
    [_opusButton release];
    [_player release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = NSLS(@"kGuessing");
    self.wordInputView.answerImage = [UIImage imageNamed:@"candidate_bg@2x.png"];
    self.wordInputView.candidateImage = [UIImage imageNamed:@"candidate_bg@2x.png"];
    
    [self initPickToolView];
    
    NSURL *url = [NSURL URLWithString:self.opus.pbOpus.image];
    NSURL *thumbUrl = [NSURL URLWithString:self.opus.pbOpus.thumbImage];
    [self.opusButton setImageUrl:url thumbImageUrl:thumbUrl placeholderImage:nil];
    
    self.player = [[[VoiceChanger alloc] init] autorelease];
    
    [[OpusService defaultService] getOpusDataFile:self.opus progressDelegate:self delegate:self];
    
    [self showActivityWithText:@"kLoadingSingData"];
}

- (void)viewDidUnload {
    
    [self setOpusButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickOpusButton:(id)sender {
    
    if ([_player isPlaying]) {
        [_player pausePlaying];
    }else{
        [_player startPlaying];
    }
}

- (IBAction)clickBack:(id)sender{
    [_player stopPlaying];
    [super clickBack:sender];
}

- (void)didGetOpusFile:(int)resultCode
                  path:(NSString *)path
                  opus:(Opus *)opus{
    
    [self hideActivity];

    NSURL *url = [NSURL fileURLWithPath:path];
    [_player prepareToPlay:url];
    [_player startPlaying];
}

- (void)didGuessCorrect:(NSString *)word{
    
    
}


@end
