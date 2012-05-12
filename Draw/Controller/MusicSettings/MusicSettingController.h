//
//  MusicSettingController.h
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"

@interface MusicSettingController : PPViewController<UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    NSArray *_musicList;
    UIWebView *_webView;
}

@property (nonatomic, retain) NSArray *musicList;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIButton *editButton;
@property (nonatomic, assign) BOOL openURLForAction;
@property (nonatomic, copy) NSString *urlForAction;

- (IBAction)clickBack:(id)sender;
- (IBAction)clickEdit:(id)sender;
@end
