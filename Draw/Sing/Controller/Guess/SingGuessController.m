//
//  SingGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-24.
//
//

#import "SingGuessController.h"
#import "UIButtonExt.h"
#import "AudioPlayer.h"
#import "FeedService.h"

@interface SingGuessController ()
@property (retain, nonatomic) AudioPlayer *player;

@end

@implementation SingGuessController

- (void)dealloc {
    [_player release];
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

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
}

- (IBAction)clickBack:(id)sender{
    [_player pauseForQuit];
    self.player = nil;
    [super clickBack:sender];
}




@end
