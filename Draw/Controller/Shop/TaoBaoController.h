//
//  TaoBaoController.h
//  Draw
//
//  Created by haodong on 13-4-1.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@interface TaoBaoController : PPViewController <UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *taoBaoWebView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *webViewBackButton;
@property (retain, nonatomic) IBOutlet UIButton *webViewForwardButton;
@property (retain, nonatomic) IBOutlet UIButton *webViewRefreshButton;

- (id)initWithURL:(NSString *)URL title:(NSString *)title;
- (id)initWithURL:(NSString *)URL title:(NSString *)title taobaoURL:(NSString*)taobaoURL;

- (IBAction)clickWebViewBack:(id)sender;
- (IBAction)clickWebViewForward:(id)sender;
- (IBAction)clickWebViewRefresh:(id)sender;

@end
