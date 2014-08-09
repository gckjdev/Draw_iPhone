//
//  GuidePageManager
//  Draw
//
//  Created by ChaoSo on 14-7-21.
//
//

#import "GuidePageManager.h"
#import "UIViewController+CommonHome.h"
#import "MetroHomeController.h"
#import "TwoInputFieldView.h"
#import "PPNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "GameNetworkConstants.h"

static BOOL gIsShowGuidePage = NO;

@implementation GuidePageManager

+ (void)showGuidePage:(UIViewController*)superController
{
    if (gIsShowGuidePage){
        // avoid reenter again
        return;
    }
    
    ICETutorialPage *layr1 = nil;
    ICETutorialPage *layr2 = nil;
    ICETutorialPage *layr3 = nil;
    ICETutorialPage *layr4 = nil;

    layr1 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-1.png"
                                          duration:3.0];
    
    layr2 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-2.png"
                                          duration:3.0];
    
    layr3 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-3.png"
                                          duration:2.0];

    layr4 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-4.png"
                                          duration:3.0];
    
    ICETutorialLabelStyle *titleStyle = [[[ICETutorialLabelStyle alloc] init] autorelease];
    
    [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
    [titleStyle setTextColor:[UIColor whiteColor]];
    [titleStyle setLinesNumber:1];
    [titleStyle setOffset:180];
    
    [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
    
    // Set the subTitles style with few properties and let the others by default.
    [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
    [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layr1,layr2,layr3,layr4];
    
    // create guide page
    GuidePageManager *guidePage = [[[GuidePageManager alloc] initWithPages:tutorialLayers delegate:nil] autorelease];
    guidePage.delegate = guidePage;
    guidePage.superController = superController;

    gIsShowGuidePage = YES;
    [superController presentViewController:guidePage animated:NO completion:^{
        
    }];
    
    [layr1 release];
    [layr2 release];
    [layr3 release];
    [layr4 release];
    
    return;
}

- (void)tutorialController:(ICETutorialController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex
{
    NSLog(@"Scrolling from page %lu to page %lu.", (unsigned long)fromIndex, (unsigned long)toIndex);
}

//左键
- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController
{
    NSLog(@"Tutorial reached the last page.");
}

//右键
- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnLeftButton:(UIButton *)sender
{
    [self showLoginDialog];

    //    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnRightButton:(UIButton *)sender
{
    [self takeNumber];

    //    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    self.superController = nil;
    
    PPRelease(_xiaojiNumber);
    PPRelease(_password);
    PPRelease(_layerList);
    [super dealloc];
}

-(void)addNewLayer:(NSString *)title WithSubTitle:(NSString *)subTitle WithPicName:(NSString *)picName WithDuration:(NSTimeInterval)duration{
   ICETutorialPage *layer  = [[ICETutorialPage alloc] initWithTitle:title
                                                            subTitle:subTitle
                                                         pictureName:picName
                                                            duration:duration];

    [self.layerList addObject:layer];
}

- (void)showLoginDialog
{
    TwoInputFieldView *rpDialog = [TwoInputFieldView create];
    
    rpDialog.textField1.placeholder = NSLS(@"kLoginXiaojiPlaceHolder");
    rpDialog.textField2.placeholder = NSLS(@"kLoginPasswordPlaceHolder");
    
    rpDialog.textField1.text = self.xiaojiNumber;
    rpDialog.textField2.text = self.password;
    
    rpDialog.textField2.secureTextEntry = YES;
    
    rpDialog.textField1.keyboardType = UIKeyboardTypeNumberPad;
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kLoginXiaoji")
                                                    customView:rpDialog
                                                         style:CommonDialogStyleDoubleButtonWithCross];
//    dialog.delegate = self;
//    dialog.tag = LOGIN_DIALOG_TAG;
    [dialog showInView:self.view];
    
    [dialog setClickOkBlock:^(TwoInputFieldView *infoView){
        
        [self processLogin:infoView.textField1.text password:infoView.textField2.text];
    }];
}

- (void)processLogin:(NSString*)number password:(NSString*)password
{
    self.xiaojiNumber = number;
    self.password = password;
    
    if ([number length] == 0){
        POSTMSG(NSLS(@"kXiaojiNumberCannotEmpty"));
        return;
    }
    
    if ([password length] == 0){
        POSTMSG(NSLS(@"kXiaojiPasswordCannotEmpty"));
        return;
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] loginUser:number password:password block:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == ERROR_SUCCESS){
            [self dismissWithMessage:NSLS(@"kLoginSuccess")];
        }
        else if (resultCode == ERROR_USERID_NOT_FOUND){
            POSTMSG(NSLS(@"kXiaojiNumberNotFound"));
        }
        else if (resultCode == ERROR_PASSWORD_NOT_MATCH){
            POSTMSG(NSLS(@"kXiaojiPasswordIncorrect"));
        }
        else{
            POSTMSG(NSLS(@"kSystemFailure"));
        }
    }];
}

- (IBAction)dismissWithMessage:(NSString*)message
{
    UIView* view = self.superController.view;
    gIsShowGuidePage = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        [CommonDialog showSimpleDialog:message inView:view];
    }];
}

- (void)takeNumber
{
    if ([[UserManager defaultManager] incAndCheckIsExceedMaxTakeNumber] == YES){
        POSTMSG(NSLS(@"kExceedMaxTakeNumber"));
        return;
    }
    
    [self showActivityWithText:NSLS(@"kRegistering")];
    [[UserNumberService defaultService] registerNewUserNumber:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == 0){
            NSString* message = [NSString stringWithFormat:NSLS(@"kTakeNumberSucc"), number];
            [self dismissWithMessage:message];
        }
        else{
            [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberFail")  inView:self.view];
        }
    }];
}

@end
