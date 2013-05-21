//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"
#import "InputAlertView.h"

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
    [self.toolHandler changeDesc:desc];
//    [self hidePopTipView];
}

- (void)changeDrawWord:(NSString*)wordText
{
    [self.toolHandler changeDrawWord:wordText];
}

@end
