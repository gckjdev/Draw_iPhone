//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"
#import "InputAlertView.h"
#import "OfflineDrawViewController.h"

#define KEYBOARD_RECT (CGRectMake(0, 228, 328, 252))

@interface EditDescCommand ()



@end


@implementation EditDescCommand

- (void)dealloc
{
    
    PPRelease(_inputAlertView);
    [super dealloc];
}

- (UIView *)showInView
{
    UIViewController *vc = [self.control theViewController];
    return vc.view;
}

    

- (id)initWithControl:(UIControl *)control itemType:(ItemType)itemType
{
    self = [super initWithControl:control itemType:itemType];
    if (self) {
        
    }
    return self;
}

-(void)sendAnalyticsReport{
    AnalyticsReport(DRAW_CLICK_EDIT_DESC);
}

- (void)comfirm:(id)msg
{
    if (isLittleGeeAPP() && [self.inputAlertView hasSubjectText]) {
        [self changeDrawWord:self.inputAlertView.subjectText];
    }
    [self changeDesc:self.inputAlertView.contentText];
    [self performSelector:@selector(hidePopTipView) withObject:nil afterDelay:0.1];
}

- (void)cancel
{
//    [self changeDesc:self.inputAlertView.contentText];
    [self performSelector:@selector(hidePopTipView) withObject:nil afterDelay:0.1];
}

- (void)showPopTipView
{
//    self.showing = YES;
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self.control theViewController];
    if (isLittleGeeAPP()) {
        self.inputAlertView = [InputAlertView inputAlertViewWith:NSLS(@"kEditOpusDesc") content:oc.opusDesc target:self commitSeletor:@selector(comfirm:) cancelSeletor:@selector(cancel) hasSNS:NO hasSubject:YES];
        [self.inputAlertView setSubjectText:oc.word.text];
    } else {
        self.inputAlertView = [InputAlertView inputAlertViewWith:NSLS(@"kEditOpusDesc") content:oc.opusDesc target:self commitSeletor:@selector(comfirm:) cancelSeletor:@selector(cancel) hasSNS:NO];
    }
    
    [self.inputAlertView showInView:oc.view animated:YES];
    if (!ISIPAD) {
        [self.inputAlertView adjustWithKeyBoardRect:KEYBOARD_RECT];
    }

}

- (BOOL)execute
{
    if ([super execute]) {
        [self showPopTipView];
        return YES;
    }
    return NO;
}

- (void)hidePopTipView
{
//    self.showing = NO;
    self.inputAlertView = nil;
}

//TODO when close the alertView, call changeDesc method
- (void)changeDesc:(NSString *)desc
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    oc.opusDesc = desc;
}

- (void)changeDrawWord:(NSString*)wordText
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    oc.word = [Word wordWithText:wordText level:0];
}

@end
