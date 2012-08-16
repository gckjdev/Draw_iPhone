//
//  WebAnnounceView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebAnnounceView.h"

@interface WebAnnounceView()
{
    UIWebView *_webView;
}
@end

@implementation WebAnnounceView

- (id)initWithAnnounce:(Announce *)anounce
{
    self = [super initWithAnnounce:anounce];
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
    if ([self.announce.url length] == 0) {
        return;
    }
    if (self.announce.type == AnnounceTypeLocal) 
    {
        [self loadLocalWebPage:self.announce.url];
    }
    else if(self.announce.type == AnnounceTypeRemote)
    {
        [self loadRemoteWebPage:self.announce.url];
    }
}


@end
