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
    
    NSURL *url = [NSURL URLWithString:self.opus.pbOpus.image];
    NSURL *thumbUrl = [NSURL URLWithString:self.opus.pbOpus.thumbImage];
    [self.opusButton setImageUrl:url thumbImageUrl:thumbUrl placeholderImage:nil];
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
    
    [[OpusService defaultService] getOpusDataFile:self.opus progressDelegate:nil delegate:self];
}

- (void)didGetOpusData:(int)resultCode
                  data:(NSData *)data
                  opus:(Opus *)opus
             fromCache:(BOOL)fromCache{
    
    self.player = [[[VoiceChanger alloc] init] autorelease];
}


@end
