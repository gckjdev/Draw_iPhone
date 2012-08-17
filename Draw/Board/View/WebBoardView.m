//
//  WebBoardView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebBoardView.h"

@interface WebBoardView()
{
    UIWebView *_webView;
}
@end

@implementation WebBoardView

- (id)initWithBoard:(Board *)board
{
    self = [super initWithBoard:board];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_webView);
    [super dealloc];
}

- (void)loadLocalWebPage:(NSString *)url
{
    
}

- (void)loadRemoteWebPage:(NSString *)url
{
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.frame];
        [_webView setDelegate:self];
        [self addSubview:_webView];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];

}

- (void)loadView
{
    [super loadView];
    /*
    if ([self.board.url length] == 0) {
        return;
    }
    if (self.board.type == BoardTypeLocal) 
    {
        [self loadLocalWebPage:self.board.url];
    }
    else if(self.board.type == BoardTypeRemote)
    {
        [self loadRemoteWebPage:self.board.url];
    }
     */
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(boardView:didCaptureRequest:)]) {
        [self.delegate boardView:self didCaptureRequest:request];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    PPDebug(@"did start load webview");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    PPDebug(@"did finish load webview");    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PPDebug(@"load webview fail");        
}

@end
