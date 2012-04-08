//
//  ReportController.h
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaSNSService.h"

typedef enum {
    SNS_SHARE = 0,
    SUBMIT_BUG,
    SUMIT_FEEDBACK
}ReportType;


@interface ReportController : PPViewController <UITextViewDelegate ,SNSServiceDelegate, UITextFieldDelegate> {
    ReportType _reportType;
}
@property (retain, nonatomic) IBOutlet UIImageView *contentBackground;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITextView *contentText;
@property (retain, nonatomic) IBOutlet UITextField *contactText;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;

- (id)initWithType:(ReportType)aType;

@end
