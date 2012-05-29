//
//  ReportController.h
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaSNSService.h"
#import "UserService.h"
typedef enum {
    SUBMIT_BUG = 0,
    SUBMIT_FEEDBACK,
    ADD_WORD
}ReportType;


@interface ReportController : PPViewController <UITextViewDelegate ,SNSServiceDelegate, UITextFieldDelegate, UserServiceDelegate> {
    ReportType _reportType;
    NSString* _lastReport;
}
@property (retain, nonatomic) IBOutlet UIImageView *contactBackground;
@property (retain, nonatomic) IBOutlet UILabel *reporterTitle;
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITextView *contentText;
@property (retain, nonatomic) IBOutlet UITextField *contactText;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (retain, nonatomic) NSString* lastReport;

- (id)initWithType:(ReportType)aType;

@end
