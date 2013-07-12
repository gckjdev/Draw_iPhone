//
//  SingOpusDetailController.m
//  Draw
//
//  Created by 王 小涛 on 13-6-11.
//
//

#import "SingOpusDetailController.h"
#import "SingUserInfoCell.h"
#import "SingOpusInfoCell.h"
#import "OpusManager.h"
#import "SingGuessController.h"
#import "UserManager.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"

@interface SingOpusDetailController ()

@end

@implementation SingOpusDetailController

- (id)init{
    if (self = [super init]) {
        self.opus = [Opus opusWithPBOpus:[OpusManager createTestOpus]] ;
        self.userInfoCellClass = [SingUserInfoCell class];
        self.opusInfoCellClass = [SingOpusInfoCell class];
        self.actionHeaderClass = [CommonCommentHeader class];
        self.guessControllerClass = [SingGuessController class];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Overwrite these methods below in your sub-class.

- (void)clickOnAuthor:(PBGameUser *)author{

}

- (void)clickOnOpus:(PBOpus *)opus{
}

- (void)clickOnTargetUser:(PBGameUser *)user{

}


@end
