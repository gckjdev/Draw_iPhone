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
#import "InputAlertView.h"

#define KEYBOARD_RECT (CGRectMake(0, 228, 328, 252))

@interface EditDescCommand ()<CommonDialogDelegate>



@end

#define DIALOG_TAG_OPUS_DESC 101
#define DIALOG_TAG_OPUS_NAME_AND_OPUS_DESC 102


@implementation EditDescCommand

- (void)dealloc
{
    
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

    if (isDrawApp()) {
        
        NSString *subject = [oc opusSubject];
        NSString *content = oc.opusDesc;
        [InputAlert showWithSubjectWithoutSNS:subject
                                      content:content
                                       inView:oc.view
                                        block:^(BOOL confirm, NSString *subject, NSString *content, NSSet *shareSet) {
                                            
                                            if (confirm) {
                                                [self changeDrawWord:subject];
                                                [self changeDesc:content];
                                            }
                                        }];
    } else {
        CommonDialog *dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kEditOpusDesc")];
        dialog.inputTextView.text = oc.opusDesc;
        dialog.delegate = self;
        dialog.tag = DIALOG_TAG_OPUS_DESC;
        [dialog showInView:oc.view];
    }
}


- (void)didClickCancel:(CommonDialog *)dialog
{
    dialog.manualClose = NO;
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(id)infoView{
    
    if (dialog.tag == DIALOG_TAG_OPUS_DESC) {
        
        UITextView *tv = (UITextView *)infoView;
        [self changeDesc:tv.text];
        
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

}

//TODO when close the alertView, call changeDesc method
- (void)changeDesc:(NSString *)desc
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    [oc setOpusDesc:desc];
}

- (void)changeDrawWord:(NSString*)wordText
{
    OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
    [oc setOpusSubject:wordText];
}

@end
