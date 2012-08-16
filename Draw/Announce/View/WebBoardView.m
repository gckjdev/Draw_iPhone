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
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
}

- (void)loadView
{
    [super loadView];
    if ([self.Board.url length] == 0) {
        return;
    }
    if (self.Board.type == BoardTypeLocal) 
    {
        [self loadLocalWebPage:self.Board.url];
    }
    else if(self.Board.type == BoardTypeRemote)
    {
        [self loadRemoteWebPage:self.Board.url];
    }
}


@end
