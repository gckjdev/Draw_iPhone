//
//  TaoBaoController.m
//  Draw
//
//  Created by haodong on 13-4-1.
//
//

#import "TaoBaoController.h"
#import "MobClickUtils.h"
#import "CommonDialog.h"

@interface TaoBaoController()
@property (retain, nonatomic) NSString *customTitle;
@property (retain, nonatomic) NSString *url;

@end

@implementation TaoBaoController

- (id)initWithURL:(NSString *)URL title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.url = URL;
        self.customTitle = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.text = self.customTitle;
    
    NSURL *url = [NSURL URLWithString:_url];
    if (url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.taoBaoWebView loadRequest:request];
        [self showActivityWithText:NSLS(@"kLoading")];
    }
    else{
        [UIUtils alert:NSLS(@"无法打开网页")];
    }
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:self.customTitle];
    [titleView setTarget:self];
    
    [self updateButtonsState];
}

- (void)clickBack:(id)sender
{
    __block TaoBaoController* vc = self;
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:NSLS(@"kQuitTaoBaoTips") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [vc.navigationController popViewControllerAnimated:YES];
    } clickCancelBlock:^{
        
    }];
    
    [dialog showInView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_taoBaoWebView release];
    [_titleLabel release];
    [_customTitle release];
    [_url release];
    [_webViewBackButton release];
    [_webViewForwardButton release];
    [_webViewRefreshButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTaoBaoWebView:nil];
    [self setTitleLabel:nil];
    [self setWebViewBackButton:nil];
    [self setWebViewForwardButton:nil];
    [self setWebViewRefreshButton:nil];
    [super viewDidUnload];
}

- (void)updateButtonsState
{
    self.webViewBackButton.enabled = [_taoBaoWebView canGoBack];
    self.webViewForwardButton.enabled = [_taoBaoWebView canGoForward];
}

- (IBAction)clickWebViewBack:(id)sender {
    [self showActivityWithText:NSLS(@"kLoading")];
    [_taoBaoWebView goBack];
}

- (IBAction)clickWebViewForward:(id)sender {
    [self showActivityWithText:NSLS(@"kLoading")];
    [_taoBaoWebView goForward];
}

- (IBAction)clickWebViewRefresh:(id)sender {
    [self showActivityWithText:NSLS(@"kLoading")];
    [_taoBaoWebView reload];
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
    [self updateButtonsState];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideActivity];
    [self updateButtonsState];
}

@end
