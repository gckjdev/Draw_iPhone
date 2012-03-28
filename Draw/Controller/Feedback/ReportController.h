//
//  ReportController.h
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaSNSService.h"


@interface ReportController : UIViewController <UITextViewDelegate ,SNSServiceDelegate> {
    
}
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UITextView *contentText;

@end
