//
//  DrawGuessController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "DrawGuessController.h"
#import "WordManager.h"
#import "CommonShareAction.h"
#import "SDImageCache.h"
#import "PPPopTableView.h"

@interface DrawGuessController ()
@property (retain, nonatomic) CommonShareAction *shareAction;

@end

@implementation DrawGuessController

- (void)dealloc {
    [_shareAction release];
    [_titleView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_titleView setTitle:NSLS(@"kGuess")];
    [_titleView setRightButtonTitle:NSLS(@"kAskForHelp")];
    [_titleView setTarget:self];
    [_titleView setRightButtonSelector:@selector(clickAskForHelpButton:)];
    
    // Set candidates
    NSString *candidates = [[WordManager defaultManager] randChineseCandidateStringWithWord:self.opus.pbOpus.name count:27];
    [self.wordInputView setCandidates:candidates column:9];
}

- (void)viewDidUnload {
    [self setTitleView:nil];
    [super viewDidUnload];
}

- (void)clickAskForHelpButton:(UIButton *)button{
    
    PPDebug(@"clickAskForHelpButton");
    
    if (_shareAction == nil) {
        _shareAction = [[CommonShareAction alloc] initWithOpus:self.opus];
    }
    
    [_shareAction popActionTags:@[@(ShareActionTagSinaWeibo), @(ShareActionTagWxFriend)] shareText:NSLS(@"kLookWhatHeDraw") viewController:self onView:_titleView.rightButton];
}

@end
