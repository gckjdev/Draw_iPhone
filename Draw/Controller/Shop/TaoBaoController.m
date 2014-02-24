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
@property (retain, nonatomic) NSString *taobaoURL;

@end

@implementation TaoBaoController

- (id)initWithURL:(NSString *)URL title:(NSString *)title taobaoURL:(NSString*)taobaoURL
{
    self = [super init];
    if (self) {
        self.url = URL;
        self.customTitle = title;
        self.taobaoURL = taobaoURL;
    }
    return self;
}

- (id)initWithURL:(NSString *)URL title:(NSString *)title
{
    return [self initWithURL:URL title:title taobaoURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDragBack:NO];
    self.titleLabel.text = self.customTitle;
    
    PPDebug(@"loading URL %@", _url);
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
    
    if ([self.taobaoURL length] > 0){
        [titleView setRightButtonTitle:@"淘宝店"];
        [titleView setRightButtonSelector:@selector(gotoTaobao)];
    }
}

- (void)gotoTaobao
{
    NSString* title = [NSString stringWithFormat:@"%@", self.customTitle];
    TaoBaoController* vc = [[TaoBaoController alloc] initWithURL:self.taobaoURL title:title taobaoURL:nil];
    [self.navigationController pushViewController:vc animated:NO];
    [vc release];
}

- (void)askGotoTaobao
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice") message:@"如果支付成功，请选择返回；如果支付失败或者无法使用支付宝，可选择去淘宝店购买" style:CommonDialogStyleDoubleButtonWithCross];
    
    [dialog.oKButton setTitle:@"淘宝购买" forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:@"返回" forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(UILabel *label){
        [self gotoTaobao];
    }];
    
    [dialog setClickCancelBlock:^(UILabel *label){
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [dialog showInView:self.view];
}

- (void)clickBack:(id)sender
{
    if ([self.taobaoURL length] == 0){
        __block TaoBaoController* vc = self;
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotice")
                                                           message:NSLS(@"kQuitTaoBaoTips")
                                                             style:CommonDialogStyleDoubleButtonWithCross];
        [dialog setClickOkBlock:^(UILabel *label){
            [vc.navigationController popViewControllerAnimated:YES];
        }];
        
        [dialog showInView:self.view];
    }
    else{
        [self askGotoTaobao];
    }
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
    PPRelease(_taobaoURL);
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
