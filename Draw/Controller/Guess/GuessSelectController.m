//
//  GuessSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessSelectController.h"
#import "Opus.h"
#import "DrawGuessController.h"

@interface GuessSelectController ()
@property (retain, nonatomic) NSArray *opuses;

@end

@implementation GuessSelectController

- (void)dealloc{
    [_opuses release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[GuessService defaultService] getOpusesWithMode:PBUserGuessModeGuessModeHappy
                                           contestId:nil
                                              offset:0
                                               limit:20
                                          isStartNew:NO];
    [[GuessService defaultService] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickOpusButton:(UIButton *)button {
    
    int index = button.tag;
    if (index >= [_opuses count]) {
        return;
    }
    
    PBOpus *pbOpus = [_opuses objectAtIndex:index];
    Opus *opus = [Opus opusWithPBOpus:pbOpus];
    
//    PPDebug(@"category = %d", pbOpus.category);
//    PPDebug(@"opusId = %@", pbOpus.opusId);
//    PPDebug(@"opusName = %@", pbOpus.name);
//    PPDebug(@"opusDesc = %@", pbOpus.desc);
//    PPDebug(@"thumbImage = %@", pbOpus.thumbImage);
//    PPDebug(@"image = %@", pbOpus.image);
//    
//    PPDebug(@"category = %@", opus.pbOpus.category);
//    PPDebug(@"opusId = %@", opus.pbOpus.opusId);
//    PPDebug(@"opusName = %@", opus.pbOpus.name);
//    PPDebug(@"opusDesc = %@", opus.pbOpus.desc);
//    PPDebug(@"thumbImage = %@", opus.pbOpus.thumbImage);
//    PPDebug(@"image = %@", opus.pbOpus.image);
    
    DrawGuessController *vc = [[[DrawGuessController alloc] initWithOpus:opus] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGetOpuses:(NSArray *)opuses resultCode:(int)resultCode{
    
    if (resultCode == 0) {
        self.opuses = opuses;
    }else{
        [self popupUnhappyMessage:NSLS(@"kLoadFailed") title:nil];
    }
}

@end
