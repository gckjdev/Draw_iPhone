//
//  EditDescCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "EditDescCommand.h"
#import "OfflineDrawViewController.h"
#import "CommonDialog.h"
#import "StringUtil.h"

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

- (void)showPopTipView
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    CommonDialog *dialog = nil;
    if (isDrawApp()) {
        
        InputAlertView *v = [InputAlertView createWithType:ComposeInputDialogTypeTitleAndContent];
        v.titleInputField.text = oc.word.text;
        v.titleInputField.placeholder = NSLS(@"kSubjectPlaceholder");
        v.contentInputView.text = oc.opusDesc;
        dialog = [CommonDialog createDialogWithTitle:NSLS(@"kEditOpusDesc") customView:v style:CommonDialogStyleDoubleButton];
        dialog.delegate = self;
        dialog.tag = DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC;
        dialog.manualClose = YES;
        
    } else {
        dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kEditOpusDesc")];
        dialog.inputTextView.text = oc.opusDesc;
        dialog.delegate = self;
        dialog.tag = DIALOG_TAG_OPUS_DESC;
    }
    
    [dialog showInView:oc.view];
}

#define SUBJECT_MAX_LENGTH 7

- (void)didClickCancel:(CommonDialog *)dialog
{
    dialog.manualClose = NO;
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView{
    
    if (dialog.tag == DIALOG_TAG_OPUS_DESC) {
        
        UITextView *tv = (UITextView *)infoView;
        [self changeDesc:tv.text];
        
    }else if(dialog.tag == DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC){
        InputAlertView *v = (InputAlertView *)infoView;
        if ([v.titleInputField.text length] <= 0) {
            POSTMSG(NSLS(@"kOpusNameInvaild"));
        }else if ((!NSStringIsValidChinese(v.titleInputField.text)&&
                   !NSStringISValidEnglish(v.titleInputField.text)
                   )){
                    POSTMSG(NSLS(@"kOnlyChineseOrEnglishTitleAllowed"));
        }else if([v.titleInputField.text length] > SUBJECT_MAX_LENGTH){
            NSString *msg = [NSString stringWithFormat:NSLS(@"kSubjectLengthLimited"),
                             SUBJECT_MAX_LENGTH];
            POSTMSG(msg);
        }else{
            [self changeDrawWord:v.titleInputField.text];
            [self changeDesc:v.contentInputView.text];
            dialog.manualClose = NO;
        }
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
