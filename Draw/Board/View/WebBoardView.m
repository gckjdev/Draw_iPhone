//
//  WebBoardView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebBoardView.h"
#import "ASIHTTPRequest.h"
#import "SSZipArchive.h"
#import "FileUtil.h"

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


- (void)loadRequestWithURL:(NSURL *)URL
{
    [_webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

#define DOWN_LOAD_FILE_NAME @"html.zip"

- (void)loadLocalWebPage
{
    
    WebBoard *webBoard = (WebBoard *)self.board;
    NSURL *localURL = [webBoard localURL];
    if (localURL) {
        PPDebug(@"<loadLocalWebPage> local url exists, URL = %@", localURL);
        [self loadRequestWithURL:localURL];
        return;
    }
    
    PPDebug(@"<loadLocalWebPage> local url NOT exists, boardID = %@, version = %@",
            webBoard.boardId,webBoard.version);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        NSString *dir = [webBoard boardLocalHtmlDir];
        if ([dir length] == 0) {
            return;
        }
//        [FileUtil removeFile:dir];
        
        NSString *destinationPath = [dir stringByAppendingPathComponent:DOWN_LOAD_FILE_NAME];
        
        // Create a request
        NSURL *URL = [NSURL URLWithString:[(WebBoard *)self.board remoteUrl]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL]; 
        [request setDownloadDestinationPath:destinationPath];
        [request startSynchronous];
        
        if (![request error]) {
            //unzip the file
            BOOL flag = [SSZipArchive unzipFileAtPath:destinationPath 
                                        toDestination:dir];
            if (flag) {
                //delete the zip file
                [FileUtil removeFile:destinationPath];
                //load the local file
                NSString *page = [dir stringByAppendingPathComponent:@"index.html"];
                NSURL *URL = [NSURL fileURLWithPath:page];
                [_webView loadRequest:[NSURLRequest requestWithURL:URL]];
                [webBoard saveLocalURL:URL];
            }else{
                PPDebug(@"error:<loadLocalWebPage> fail to unzip file = %@", destinationPath);
            }
        }else{
            PPDebug(@"error:<loadLocalWebPage>  down load fail, error = %@", [request error]);
        }

    });
}

- (void)loadView
{
    [super loadView];
    WebBoard *webBoard = (WebBoard *)self.board;
    if (webBoard.webType == WebTypeRemote) {
        [self loadRequestWithURL:[webBoard remoteURL]];
    }else if(webBoard.webType == WebTypeLocal){
        [self loadLocalWebPage];
    }
}

- (void)viewDidDisappear
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    if ([self handleTap:request.URL]) {
        PPDebug(@"should NOT load request = %@", request.URL);
        return NO;
    }else{
        PPDebug(@"should load request = %@", request.URL);
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    PPDebug(@"did start load webview");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    PPDebug(@"did finish load webview");    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    PPDebug(@"<WebBoardView>load webview fail,error = %@",error);        
}

@end
