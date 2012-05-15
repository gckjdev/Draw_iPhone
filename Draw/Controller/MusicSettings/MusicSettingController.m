//
//  MusicSettingController.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicSettingController.h"
#import "MusicSettingCell.h"
#import "MusicItem.h"
#import "MusicDownloadService.h"
#import "MusicItem.h"
#import "LogUtil.h"
#import "MusicItemManager.h"
#import "ShareImageManager.h"

#define MUSIC_URL @"http://m.easou.com/"

@implementation MusicSettingController

@synthesize tableView = _tableView;
@synthesize webView = _webView;
@synthesize editButton;
@synthesize musicList = _musicList;
@synthesize canDelete;
@synthesize request;
@synthesize openURLForAction;
@synthesize urlForAction;
@synthesize musicLabel;
@synthesize expandButton;
@synthesize previousButton;
@synthesize nextButton;
@synthesize stopButton;
@synthesize refreshButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)openURL:(NSString *)URLString
{
//    [self showActivityWithText:NSLS(@"kLoadingURL")];
    
    NSLog(@"url = %@",URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

enum{
    EXPAND = 1,
    COLLAPSE
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];    
    [editButton setBackgroundImage:[imageManager orangeImage] 
                          forState:UIControlStateNormal];
    
    expandButton.tag = EXPAND;
    [self setActionButtonsHidden:YES];

    
    [self openURL:MUSIC_URL];
    
    _musicList = [[MusicItemManager defaultManager] findAllItems];
//    _musicList = [[MusicDownloadService defaultService] findAllItems];
    
    //for test
//    MusicItem *item = [[MusicItem alloc] initWithUrl:@"test" fileName:@"test" filePath:@"" tempPath:@""];
//    MusicItem *item2 = [[MusicItem alloc] initWithUrl:@"test" fileName:@"test2" filePath:@"" tempPath:@""];
//    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:item, item2, nil];
//    self.musicList = array ;

    [self createTimer];
    
}

- (void)updateProgressTimer
{
//    _musicList = [[MusicItemManager defaultManager] findAllItems];
//    _musicList = [[MusicDownloadService defaultService] findAllItems];
//    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
    self.tableView = nil;
    self.request = nil;
    self.musicList = nil;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [super dealloc];
    [self.webView release];
    [self.request release];
    [self.tableView release];
    [self.musicList release];
    [self.timer release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)createTimer
{
    if (timer != nil){
        [timer invalidate];
        timer = nil;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                  target: self
                                                selector: @selector(updateProgressTimer)
                                                userInfo: nil
                                                 repeats: YES];
}

- (void)killTimer
{
    [timer invalidate];
    timer = nil; 
}

#pragma mark - Button Action
- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickEdit:(id)sender;
{
    if ([_musicList count] == 0) {
        return;
    }
    
    self.canDelete = !canDelete;
    [self.tableView setEditing:canDelete animated:YES];
    [self.tableView reloadData];
    
    if (canDelete) {
        [self killTimer];
    }
    else {
        [self createTimer];
    }
}

-(IBAction)clickExpand:(id)sender
{
    if (self.expandButton.tag == EXPAND) {
        [self.tableView setHidden:YES];
        [self.editButton setHidden:YES];
        
        CGRect labelframe = self.musicLabel.frame;
        labelframe.origin.y=50;
        
        CGRect expandframe = self.expandButton.frame;
        expandframe.origin.y=50;
        
        CGRect webframe=self.webView.frame;
        webframe.origin.y=50+30;
        webframe.size.height = [UIScreen mainScreen].bounds.size.height - 50 - 30 - 50;
                
        [UIView animateWithDuration:0.5 animations:^{ 
            self.webView.frame=webframe;
            self.expandButton.frame = expandframe;
            self.musicLabel.frame = labelframe;
            [self.expandButton setTitle:NSLS(@"收缩") forState:UIControlStateNormal];
            self.expandButton.tag = COLLAPSE;
            [self setActionButtonsHidden:NO];

            
        }];
    }
    else {
        [self.tableView setHidden:NO];
        [self.editButton setHidden:NO];

        CGRect labelframe = self.musicLabel.frame;
        labelframe.origin.y=210;
        
        CGRect expandframe = self.expandButton.frame;
        expandframe.origin.y=210;
        
        CGRect webframe=self.webView.frame;
        webframe.origin.y=210+30;
        webframe.size.height = [UIScreen mainScreen].bounds.size.height - 30 - 50;
        
        [UIView animateWithDuration:0.5 animations:^{ 
            
            self.webView.frame=webframe;
            self.expandButton.frame = expandframe;
            self.musicLabel.frame = labelframe;
            [self.expandButton setTitle:NSLS(@"展开") forState:UIControlStateNormal];
            self.expandButton.tag = EXPAND;
            [self setActionButtonsHidden:YES];


        }];

    }
}

#pragma mark - tableView delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;		
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  40.0f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [self.musicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"MusicSettingCell";
    MusicSettingCell *cell = (MusicSettingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [MusicSettingCell createCell:self];
	}
    
    cell.indexPath = indexPath;
    
	int row = [indexPath row];	
	int count = [_musicList count];
	if (row >= count){
		NSLog(@"[WARN] cellForRowAtIndexPath, row(%d) > data list total number(%d)", row, count);
		return cell;
	}
	
    MusicItem* downloadItem = [self.musicList objectAtIndex:row];
    [cell setCellInfoWithItem:downloadItem indexPath:indexPath];    

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicItem *item = [_musicList objectAtIndex:indexPath.row];
    NSMutableArray *mutableDataList = [NSMutableArray arrayWithArray:_musicList];
    [mutableDataList removeObjectAtIndex:indexPath.row];
    _musicList = mutableDataList;
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [[MusicItemManager defaultManager] deleteItem:item];
    
    [self createTimer];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (canDelete) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - webView delegate method
- (void) setActionButtonsHidden:(BOOL)isHidden
{
    [self.previousButton setHidden:isHidden];
    [self.nextButton setHidden:isHidden];
    [self.stopButton setHidden:isHidden];
    [self.refreshButton setHidden:isHidden];
}
- (IBAction)clickPrevious:(id)sender
{
    if (self.webView.canGoBack) {
        [self.webView stopLoading];
        [self.webView goBack];
    } 
}
- (IBAction)clicknext:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView stopLoading];
        [self.webView goForward];
    }
}
- (IBAction)clickStop:(id)sender
{
    [self.webView stopLoading];
}
- (IBAction)clickRefresh:(id)sender
{
    [self.webView reload];
}

- (BOOL)canDownload:(NSString*)urlString
{    
    NSString* pathExtension = [[urlString pathExtension] lowercaseString];
    if (pathExtension == nil)
        return NO;
    
    NSSet* fileTypeSet = [NSSet setWithObjects:@"mp3", @"mid", @"mp4", @"zip", @"3pg", @"mov", 
                          @"jpg", @"png", @"jpeg", 
                          @"avi", @"pdf", @"doc", @"txt", @"gif", @"xls", @"ppt", @"rtf",
                          @"rar", @"tar", @"gz", @"flv", @"rm", @"rmvb", @"ogg", @"wmv", @"m4v",
                          @"bmp", @"wav", @"caf", @"m4v", @"aac", @"aiff", @"dvix", @"epub",
                          nil];
    return [fileTypeSet containsObject:pathExtension];
}

- (void)askDownload:(NSString*)urlString
{
    self.urlForAction = urlString;
    self.openURLForAction = NO;
    
    NSString* title = [NSString stringWithFormat:NSLS(@"kDownloadURL"), urlString];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLS(@"Cancel") destructiveButtonTitle:NSLS(@"kYesDownload") otherButtonTitles:NSLS(@"kNoOpenURL"), nil];
    
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    enum BUTTON_INDEX {
        CLICK_DOWNLOAD = 0,
        CLICK_OPEN_URL = 1
    };
    
    switch (buttonIndex) {
        case CLICK_DOWNLOAD:
        {
            [[MusicDownloadService defaultService] downloadFile:urlForAction];
            
        }
            break;
            
        case CLICK_OPEN_URL:
        {
            self.openURLForAction = YES;
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlForAction]]];
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)isURLSkip:(NSString*)urlString
{
    if ([urlString rangeOfString:@":4022"].location != NSNotFound){
        NSLog(@"URL(%@) contains 4022, skip it", urlString);
        return YES;
    }
    else
        return NO;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)requestURL navigationType:(UIWebViewNavigationType)navigationType
{
    
    PPDebug(@"Loading URL = %@", [[requestURL URL] absoluteURL]); 

    NSString* urlString = [[[requestURL URL] absoluteURL] description];
    if ([self isURLSkip:urlString]){
        return YES;
    }
    
    if (openURLForAction == YES && [self.urlForAction isEqualToString:urlString]){
        // it's already confirmed to open the URL by askDownload
        return YES;
    }
    
    // remove query parameter string
    NSString* baseURLString = [[[requestURL URL] absoluteURL] description];
    NSString* path = baseURLString;
    NSString* para = [[[requestURL URL] absoluteURL] query];
    if (para != nil){
        path = [path stringByReplacingOccurrencesOfString:[@"?" stringByAppendingString:para]
                                               withString:@""];
    }
    
    if ([self canDownload:baseURLString] || [self canDownload:path]){
        [self askDownload:urlString];
        return NO;
    }
    
    return YES;

}

@end
