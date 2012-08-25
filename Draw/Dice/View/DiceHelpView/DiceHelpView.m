//
//  DiceHelpView.m
//  Draw
//
//  Created by 小涛 王 on 12-8-24.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceHelpView.h"
#import "FileUtil.h"

#define HTML_FILE_NAME_GAME_RULES @"help/dice/gameRules.html"
#define HTML_FILE_NAME_ITMES_USAGE @"help/dice/itemsUsage.html"

#define HTML_FILE_PATH_GAME_RULES [[FileUtil getAppHomeDir] stringByAppendingPathComponent:HTML_FILE_NAME_GAME_RULES]
#define HTML_FILE_PATH_ITMES_USAGE [[FileUtil getAppHomeDir] stringByAppendingPathComponent:HTML_FILE_NAME_ITMES_USAGE]

@interface DiceHelpView ()

@end

@implementation DiceHelpView

// just replace PPTableViewCell by the new Cell Class Name
@synthesize webView;
@synthesize gameRulesButton;
@synthesize itemsUsageButton;


+ (id)createDiceHelpView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DiceHelpView" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    return [topLevelObjects objectAtIndex:0];;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        webView.delegate = self;
        
        gameRulesButton.selected = YES;
        itemsUsageButton.selected = NO;
        
        [self loadHtmlFile:HTML_FILE_PATH_GAME_RULES];
    }
    
    return self;
}


- (void)dealloc {
    [webView release];
    [gameRulesButton release];
    [itemsUsageButton release];
    [super dealloc];
}
- (IBAction)clickCloseButton:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)clickGameRulesButton:(id)sender {
    gameRulesButton.selected = YES;
    itemsUsageButton.selected = NO;
    
    [self loadHtmlFile:HTML_FILE_PATH_GAME_RULES];
}

- (IBAction)clickItemsUsageButton:(id)sender {
    gameRulesButton.selected = NO;
    itemsUsageButton.selected = YES;
    
    [self loadHtmlFile:HTML_FILE_PATH_ITMES_USAGE];
}

- (void)loadHtmlFile:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
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
