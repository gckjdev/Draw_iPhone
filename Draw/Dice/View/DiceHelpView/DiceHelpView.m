//
//  DiceHelpView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceHelpView.h"
#import "DiceHelpManager.h"
#import "DiceImageManager.h"

@interface DiceHelpView ()
{
    DiceHelpManager *_helpManager;
    AnimationType _animationType;
}

@end

@implementation DiceHelpView

@synthesize delegate = _delegate;

// just replace PPTableViewCell by the new Cell Class Name
@synthesize bgImageView;
@synthesize webView;
@synthesize gameRulesButton;
@synthesize itemsUsageButton;

- (void)dealloc {
    [webView release];
    [gameRulesButton release];
    [itemsUsageButton release];
    [bgImageView release];
    [super dealloc];
}

+ (id)createDiceHelpView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceHelpView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];
}

- (void)initialize
{
    _helpManager = [DiceHelpManager defaultManager];
    
    bgImageView.image = [[DiceImageManager defaultManager] popupBackgroundImage];
    webView.delegate = self;
    gameRulesButton.selected = YES;
    itemsUsageButton.selected = NO;
    
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
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}


@end
