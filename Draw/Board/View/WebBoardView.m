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
        _webView = [[UIWebView alloc] initWithFrame:self.bounds];
        [_webView setDelegate:self];
        [self addSubview:_webView];
        [_webView setScalesPageToFit:YES];
         
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
    PPDebug(@"start to load remote web page, ulr = %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];      
    [_webView loadRequest:request];

}

- (void)loadView
{
    [super loadView];
    WebBoard *webBoard = (WebBoard *)self.board;
    if (webBoard.webType == WebTypeRemote) {
        [self loadRemoteWebPage:webBoard.remoteUrl];
    }else if(webBoard.webType == WebTypeLocal){
        [self loadRemoteWebPage:webBoard.localUrl];
    }
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
