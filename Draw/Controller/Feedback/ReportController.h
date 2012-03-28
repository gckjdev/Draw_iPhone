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
    REPORT_BUG,
    FEEDBACK
}ReportType;


@interface ReportController : UIViewController <UITextViewDelegate ,SNSServiceDelegate> {
    ReportType _reportType;
}
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITextView *contentText;

- (id)initWithType:(ReportType)aType;

@end
