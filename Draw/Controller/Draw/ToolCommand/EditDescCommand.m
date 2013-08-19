//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"
//#import "InputAlertView.h"
#import "OfflineDrawViewController.h"
#import "CommonDialog.h"

#define KEYBOARD_RECT (CGRectMake(0, 228, 328, 252))

@interface EditDescCommand ()<CommonDialogDelegate>



@end

#define DIALOG_TAG_OPUS_DESC 101
#define DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC 102


@implementation EditDescCommand

- (void)dealloc
{
    
//    PPRelease(_inputAlertView);
    [super dealloc];
}

- (UIView *)showInView
{
    UIViewController *vc = [self controller];
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

//- (void)comfirm:(id)msg
//{
//    if (isLittleGeeAPP() && [self.inputAlertView hasSubjectText]) {
//        [self changeDrawWord:self.inputAlertView.subjectText];
//    }
//    [self changeDesc:self.inputAlertView.contentText];
//    [self performSelector:@selector(hidePopTipView) withObject:nil afterDelay:0.1];
//}

//- (void)cancel
//{
////    [self changeDesc:self.inputAlertView.contentText];
//    [self performSelector:@selector(hidePopTipView) withObject:nil afterDelay:0.1];
//}

- (void)showPopTipView
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    CommonDialog *dialog = nil;
    if (isLittleGeeAPP()) {
//        self.inputAlertView = [InputAlertView inputAlertViewWith:NSLS(@"kEditOpusDesc") content:oc.opusDesc target:self commitSeletor:@selector(comfirm:) cancelSeletor:@selector(cancel) hasSNS:NO hasSubject:YES];
//        [self.inputAlertView setSubjectText:oc.word.text];
        
        InputAlertView *v = [InputAlertView createWithType:ComposeInputDialogTypeTitleAndContent];
        v.titleInputField.text = oc.word.text;
        
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kEditOpusDesc") customView:v style:CommonDialogStyleDoubleButton];
        dialog.delegate = self;
        dialog.tag = DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC;
        
    } else {
        dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kEditOpusDesc")];
        dialog.inputTextView.text = oc.opusDesc;
        dialog.delegate = self;
        dialog.tag = DIALOG_TAG_OPUS_DESC;
    }
    
    [dialog showInView:oc.view];
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView{
    
    if (dialog.tag == DIALOG_TAG_OPUS_DESC) {
        
        UITextView *tv = (UITextView *)infoView;
        [self changeDesc:tv.text];
        
    }else if(dialog.tag == DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC){
        
        InputAlertView *v = (InputAlertView *)infoView;
        [self changeDrawWord:v.titleInputField.text];
        [self changeDesc:v.contentInputView.text];
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
//    self.inputAlertView = nil;
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
