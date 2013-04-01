//
//  TaoBaoController.m
//  Draw
//
//  Created by haodong on 13-4-1.
//
//

#import "TaoBaoController.h"
#import "MobClickUtils.h"

// TO DO UPDATE
#define KEY_TAOBAO_URL  @"kTaoBao"


@implementation TaoBaoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSString *urlString = [MobClickUtils getStringValueByKey:KEY_TAOBAO_URL defaultValue:nil];
    NSString *urlString = @"http://a.m.taobao.com/i19338999705.htm?v=0&mz_key=0";
    
    if (urlString) {
         NSURL *url = [NSURL URLWithString:urlString];
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
