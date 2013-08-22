//
//  ContestView.h
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contest;
@class ContestView;
@protocol ContestViewDelegate <NSObject>

@optional
- (void)didClickContestView:(ContestView *)contestView 
               onOpusButton:(Contest *)contest;

- (void)didClickContestView:(ContestView *)contestView
               onJoinButton:(Contest *)contest;

- (void)didClickContestView:(ContestView *)contestView
             onDetailButton:(Contest *)contest;

- (void)didClickContestView:(ContestView *)contestView
             onReportButton:(Contest *)contest;

@end

@interface ContestView : UIView<UIWebViewDelegate>
{
    id<ContestViewDelegate> _delegate;
    Contest *_contest;
}
@property(nonatomic, assign)id<ContestViewDelegate>delegate;
@property(nonatomic, retain)Contest *contest;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (retain, nonatomic) IBOutlet UILabel *opusLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UILabel *joinLabel;
@property (retain, nonatomic) IBOutlet UILabel *reportLabel;

+ (id)createContestView:(id)delegate;
+ (CGFloat)getViewWidth;
+ (CGFloat)getViewHeight;
- (IBAction)clickOpusButton:(id)sender;
- (IBAction)clickDetailButton:(id)sender;
- (IBAction)clickJoinButton:(id)sender;
- (IBAction)clickReportButton:(id)sender;
- (void)setViewInfo:(Contest *)contest;
- (void)refreshCount;
- (void)refreshRequest;
@end
