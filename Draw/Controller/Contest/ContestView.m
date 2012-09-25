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
    
//    [(UIScrollView *) [[self.webView subviews] objectAtIndex:0] setBounces:NO];
    self.contest = contest;    
    [self refreshRequest];
    [self.webView.scrollView setScrollEnabled:NO];
    //set count
    NSString *opusTitle = [NSString stringWithFormat:NSLS(@"kOpusCount"),
                           contest.opusCount];
    [self.opusLabel setText:opusTitle];
    
    NSString *joinTitle = [NSString stringWithFormat:NSLS(@"kJoinCount"),
                           contest.participantCount];
    [self.joinLabel setText:joinTitle];
    [self.detailLabel setText:NSLS(@"kDetail")];
}

- (void)refreshRequest
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:self.contest.contestUrl]];

    [self.webView loadRequest:request];
}

+ (CGFloat)getViewWidth
{
    return [DeviceDetection isIPAD] ? 600 : 320;
}
+ (CGFloat)getViewHeight
{
    return [DeviceDetection isIPAD] ? 900 : 390;
}

#pragma mark - web view delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    PPDebug(@"<webViewDidFinishLoad>");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PPDebug(@"<didFailLoadWithError>, error = %@",error);
}


@end
