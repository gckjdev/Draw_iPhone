//
//  TaoBaoController.m
//  Draw
//
//  Created by haodong on 13-4-1.
//
//

#import "TaoBaoController.h"

@interface TaoBaoController ()

@end

@implementation TaoBaoController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:@"http://a.m.taobao.com/i19338999705.htm?v=0&mz_key=0"];
    if (url) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.taoBaoWebView loadRequest:request];
        
        [self showActivityWithText:NSLS(@"kLoading")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_taoBaoWebView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTaoBaoWebView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivity];
}

@end
