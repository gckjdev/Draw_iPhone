//
//  StatementView.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contest;
@interface StatementView : UIView
{
    UIWebView *_webView;
    id _delegate;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic, assign)id delegate;
@property (retain, nonatomic) IBOutlet UIImageView *playProgressLoad;

+ (id)createStatementView:(id)delegate;
- (IBAction)clickCloseButton:(id)sender;
- (void)setViewInfo:(Contest *)contest;
- (void)showInView:(UIView *)view;
@end
