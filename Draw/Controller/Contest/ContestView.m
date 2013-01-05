//
//  ContestView.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ContestView.h"
#import "Contest.h"
//#import <QuartzCore/QuartzCore.h>
#import "ShareImageManager.h"
#import "UIButtonExt.h"
@implementation ContestView

@synthesize delegate = _delegate;
@synthesize contest = _contest;

@synthesize webView = _webView;
@synthesize bgView = _bgView;
@synthesize activity = _activity;
@synthesize opusLabel = _opusLabel;
@synthesize detailLabel = _detailLabel;
@synthesize joinLabel = _joinLabel;

+ (id)createContestView:(id)delegate
{
    NSString* identifier = @"ContestView";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    ContestView *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    return view;
}

- (void)dealloc
{
    PPRelease(_contest);
    PPRelease(_joinLabel);
    PPRelease(_opusLabel);
    PPRelease(_detailLabel);
    PPRelease(_webView);
    PPRelease(_bgView);
    [_activity release];
    [super dealloc];
}

- (IBAction)clickOpusButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickContestView:onOpusButton:)]) {
        [self.delegate didClickContestView:self onOpusButton:self.contest];
    }
}

- (IBAction)clickDetailButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickContestView:onDetailButton:)]) {
        [self.delegate didClickContestView:self onDetailButton:self.contest];
    }
}

- (IBAction)clickJoinButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickContestView:onJoinButton:)]) {
        [self.delegate didClickContestView:self onJoinButton:self.contest];
    }
}


- (void)setViewInfo:(Contest *)contest
{
    self.contest = contest;    
    [self refreshRequest];
    [self refreshCount];
    if ([DeviceDetection isOS5]) {
        [self.webView.scrollView setScrollEnabled:NO];
    }else{
        for (UIScrollView *view in self.webView.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                view.scrollEnabled = NO;
            }
        }
    }

    [self.detailLabel setText:NSLS(@"kContestRule")];
}

- (void)refreshRequest
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:self.contest.contestUrl]];

    [self.webView loadRequest:request];
}

- (void)refreshCount
{
    //set count
    NSString *opusTitle = [NSString stringWithFormat:NSLS(@"kOpusCount"),
                           _contest.opusCount];
    [self.opusLabel setText:opusTitle];
    
    NSString *joinTitle = nil;
    
    if ([_contest isPassed]) {
        joinTitle = [NSString stringWithFormat:NSLS(@"kContestPassed"),
                     _contest.participantCount];        
        
    }else if([_contest isPending]){
        joinTitle = NSLS(@"kContestPending");        
        
    }else{
        joinTitle = [NSString stringWithFormat:NSLS(@"kJoinCount"),
                     _contest.participantCount];        
    }
    
    [self.joinLabel setText:joinTitle];

}
+ (CGFloat)getViewWidth
{
    return [DeviceDetection isIPAD] ? 768 : 320;
}
+ (CGFloat)getViewHeight
{
    return [DeviceDetection isIPAD] ? 851 : 390;
}

#pragma mark - web view delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    PPDebug(@"<webViewDidFinishLoad>");
    [self.activity stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PPDebug(@"<didFailLoadWithError>, error = %@",error);
}


@end
