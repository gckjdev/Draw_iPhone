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
@end

@interface ContestView : UIView<UIWebViewDelegate>
{
    id<ContestViewDelegate> _delegate;
    Contest *_contest;
}
@property(nonatomic, assign)id<ContestViewDelegate>delegate;
@property(nonatomic, retain)Contest *contest;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;
@property (retain, nonatomic) IBOutlet UIButton *detailButton;
@property (retain, nonatomic) IBOutlet UIButton *joinButton;
@property (retain, nonatomic) IBOutlet UIImageView *bgView;


+ (id)createContestView:(id)delegate;
+ (CGFloat)getViewWidth;
+ (CGFloat)getViewHeight;
- (IBAction)clickOpusButton:(id)sender;
- (IBAction)clickDetailButton:(id)sender;
- (IBAction)clickJoinButton:(id)sender;
- (void)setViewInfo:(Contest *)contest;
- (void)refreshRequest;
@end
