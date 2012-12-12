//
//  HelpView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "HelpView.h"
#import "DiceHelpManager.h"
#import "DiceImageManager.h"
#import "PPResourceService.h"

@interface HelpView ()
{
    DiceHelpManager *_helpManager;
    AnimationType _animationType;
    PPResourceService *_resService;
}

@end

@implementation HelpView

@synthesize delegate = _delegate;

// just replace PPTableViewCell by the new Cell Class Name
@synthesize bgImageView;
@synthesize webView;
@synthesize gameRulesButton;
@synthesize itemsUsageButton;
@synthesize indicator;

- (void)dealloc {
    [webView release];
    [gameRulesButton release];
    [itemsUsageButton release];
    [bgImageView release];
    [indicator release];
    [_closeButton release];
    [super dealloc];
}

+ (id)createHelpView:(NSString *)nibName
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    UIView* view = [topLevelObjects objectAtIndex:0];
    view.tag = DICE_HELP_VIEW_TAG;
    return view;
}

- (void)initialize
{
    _helpManager = [DiceHelpManager defaultManager];
    _resService = [PPResourceService defaultService];
    
    bgImageView.image = [[_resService imageByName:[getGameApp() helpViewBgImageName] inResourcePackage:[getGameApp() resourcesPackage]] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    
    [self.closeButton setBackgroundImage:[_resService imageByName:[getGameApp() popupViewCloseBtnBgImageName] inResourcePackage:[getGameApp() resourcesPackage]]  forState:UIControlStateNormal];
    
    webView.delegate = self;
    
    [gameRulesButton setBackgroundImage:[_resService imageByName:[getGameApp() gameRulesButtonBgImageNameForNormal] inResourcePackage:[getGameApp() resourcesPackage]] forState:UIControlStateNormal];
    
    [gameRulesButton setBackgroundImage:[_resService imageByName:[getGameApp() gameRulesButtonBgImageNameForSelected] inResourcePackage:[getGameApp() resourcesPackage]] forState:UIControlStateSelected];
    
    [itemsUsageButton setBackgroundImage:[_resService imageByName:[getGameApp() itemsUsageButtonBgImageNameForNormal] inResourcePackage:[getGameApp() resourcesPackage]] forState:UIControlStateNormal];
    
    [itemsUsageButton setBackgroundImage:[_resService imageByName:[getGameApp() itemsUsageButtonBgImageNameForSelected] inResourcePackage:[getGameApp() resourcesPackage]] forState:UIControlStateSelected];
    
    gameRulesButton.selected = YES;
    itemsUsageButton.selected = NO;
    indicator.hidesWhenStopped = YES;
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [self.gameRulesButton.fontLable setText:NSLS(@"kDiceGameRules")];
    [self.itemsUsageButton.fontLable setText:NSLS(@"kDicePropDescription")];
    
    [self loadHtmlFile:[_helpManager gameRulesHtmlFilePath]];
}

- (AnimationType)randomAnimationType
{
    srand((unsigned)time(0)); 
    int ran_num = rand() % 3; 
    
    return ran_num + 1;
}

- (void)showInView:(UIView *)view
{
    self.frame = view.frame;
    [self showInView:view animationType:[self randomAnimationType]];
}


- (void)showInView:(UIView *)view 
     animationType:(AnimationType)animationType
{
    [self initialize];
    _animationType = animationType;
    
    switch (animationType) {
        case AnimationTypeCaseInCaseOut:
            [self showInViewCaseInCaseOut:view];
            break;

        case AnimationTypeUpToDown:
            [self showInViewUpToDown:view];
            break;
            
        case AnimationTypeLeftToRight:
            [self showInViewLeftToRight:view];
            break;
        default:
            break;
    }
}

- (void)showInViewCaseInCaseOut:(UIView *)view
{
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)removeCaseInCaseOut
{
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showInViewUpToDown:(UIView *)view
{
    self.frame = CGRectMake(self.frame.origin.x, -self.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)removeUpToDown
{
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showInViewLeftToRight:(UIView *)view
{
    self.frame = CGRectMake(-self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)removeLeftToRight
{
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)hide
{
    switch (_animationType) {
        case AnimationTypeCaseInCaseOut:
            [self removeCaseInCaseOut];
            break;
            
        case AnimationTypeUpToDown:
            [self removeUpToDown];
            break;
            
        case AnimationTypeLeftToRight:
            [self removeLeftToRight];
            break;
        default:
            break;
    }
}

- (IBAction)clickCloseButton:(id)sender {
    [self hide];
    
    if ([_delegate respondsToSelector:@selector(didHelpViewHide)]) {
        [_delegate didHelpViewHide];
    }
}

- (IBAction)clickGameRulesButton:(id)sender {
    gameRulesButton.selected = YES;
    itemsUsageButton.selected = NO;
    
    [self loadHtmlFile:[_helpManager gameRulesHtmlFilePath]];
}

- (IBAction)clickItemsUsageButton:(id)sender {
    gameRulesButton.selected = NO;
    itemsUsageButton.selected = YES;
    
    [self loadHtmlFile:[_helpManager itemsUsageHtmlFilePath]];
}

- (void)loadHtmlFile:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if (url == nil){
        PPDebug(@"<DiceHelpView> loadHtmlFile but URL nil, filePath=%@", filePath);
        return;
    }
    
    // Request from a url, load request to web view.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    PPDebug(@"Help URL: %@", request.description);
    if (request) {
        [webView loadRequest:request];        
    }
}

#pragma mark -
#pragma mark: implementation of web view delegate.
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [indicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [indicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [indicator stopAnimating];
}


@end
