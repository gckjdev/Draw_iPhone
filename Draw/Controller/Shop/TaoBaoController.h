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

- (id)initWithURL:(NSString *)URL title:(NSString *)title;

@end
