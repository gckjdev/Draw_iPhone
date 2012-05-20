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
#import "AudioManager.h"
#import "ConfigManager.h"
#import "DeviceDetection.h"

@implementation MusicSettingController

@synthesize tableView = _tableView;
@synthesize webView = _webView;
@synthesize editButton;
@synthesize musicList = _musicList;
@synthesize canDelete = _canDelete;
@synthesize request;
@synthesize openURLForAction;
@synthesize urlForAction;
@synthesize musicLabel;
@synthesize expandButton;
@synthesize previousButton;
@synthesize nextButton;
@synthesize stopButton;
@synthesize refreshButton;
@synthesize audiomanager;
@synthesize musicSettingTitleLabel;

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
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_bg2@2x.png"]]];
    
    self.musicSettingTitleLabel.text = NSLS(@"kMusicSettings");
    [self.editButton setTitle:NSLS(@"kEdit") forState:UIControlStateNormal];
    self.musicLabel.text = NSLS(@"kCustomMusicDownload");
    [musicLabel setTextColor:[UIColor brownColor]];

    [self.expandButton setTitle:NSLS(@"kExpand") forState:UIControlStateNormal];
    [self.previousButton setTitle:NSLS(@"kPrevious") forState:UIControlStateNormal];
    [self.nextButton setTitle:NSLS(@"kNext") forState:UIControlStateNormal];
    [self.refreshButton setTitle:NSLS(@"kRefresh") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLS(@"kStop") forState:UIControlStateNormal];

    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];    
    [editButton setBackgroundImage:[imageManager orangeImage] 
                          forState:UIControlStateNormal];
    [expandButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [previousButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [nextButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [refreshButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [stopButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    
    self.expandButton.tag = EXPAND;
    [self setActionButtonsHidden:YES];
    [self openURL:[ConfigManager getMusicDownloadHomeURL]];
    
    _musicList = [[MusicItemManager defaultManager] findAllItems];
    

    [self createTimer];
    
    audiomanager = [AudioManager defaultManager];
    
    //for webView GestureRecongize
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.webView addGestureRecognizer:tapGesture];
    [tapGesture release];
            
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.expandButton.tag == EXPAND) {
            [self clickExpand:self];
        }
    }
}

- (void)updateProgressTimer
{
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

-(void)viewDidDisappear:(BOOL)animated
{
    [[MusicItemManager defaultManager] saveMusicItems];
}

- (void)dealloc
{
    [super dealloc];
    [_webView release];
    [request release];
    [_tableView release];
    [_musicList release];
    [timer release];
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
        [timer release];
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
    [timer release];
}

#pragma mark - Button Action
- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickEdit:(id)sender;
{
    _canDelete = !_canDelete;
    [self.tableView setEditing:_canDelete animated:YES];
    
    if (_canDelete == YES) {
        [self killTimer];
    }
    else {
        _musicList = [[MusicItemManager defaultManager] findAllItems];
        [self createTimer];
    }
}

-(IBAction)clickExpand:(id)sender
{
    if (self.expandButton.tag == EXPAND) {
        [self.tableView setHidden:YES];
        [self.editButton setHidden:YES];
        
        int labelMarginY;
        int buttonMarginY;
        int frameMarginY;
        int footerHeight;
        if ([DeviceDetection isIPAD]){
            labelMarginY = 105;
            buttonMarginY = 105;
            frameMarginY = 150;
            footerHeight = 70;
        }else {
            labelMarginY = 50;
            buttonMarginY = 50;
            frameMarginY = 82;
            footerHeight = 60;
        }
        
        CGRect labelframe = self.musicLabel.frame;
        labelframe.origin.y=labelMarginY;
        labelframe.origin.x=9;
        
        CGRect expandframe = self.expandButton.frame;
        expandframe.origin.y=buttonMarginY;
        
        CGRect webframe=self.webView.frame;
        webframe.origin.y=frameMarginY;
        webframe.origin.x=0;
        webframe.size.width = [UIScreen mainScreen].bounds.size.width;
        webframe.size.height = [UIScreen mainScreen].bounds.size.height - frameMarginY - footerHeight;
                
        [UIView animateWithDuration:0.5 animations:^{ 
            self.webView.frame=webframe;
            self.expandButton.frame = expandframe;
            self.musicLabel.frame = labelframe;
            [self.expandButton setTitle:NSLS(@"kCollapse") forState:UIControlStateNormal];
            self.expandButton.tag = COLLAPSE;
            [self setActionButtonsHidden:NO];

            
        }];
    }
    else {
        [self.tableView setHidden:NO];
        [self.editButton setHidden:NO];

        int labelMarginY;
        int buttonMarginY;
        int frameMarginY;
        int frameMarginX;
        int footerHeight;
        
        if ([DeviceDetection isIPAD]){
            labelMarginY = 425;
            buttonMarginY = 422;
            frameMarginY = 465;
            frameMarginX = 40;
            footerHeight = 70;
        }else {
            labelMarginY = 215;
            buttonMarginY = 215;
            frameMarginY = 247;
            frameMarginX = 9;
            footerHeight = 60;
        }

        CGRect labelframe = self.musicLabel.frame;
        labelframe.origin.y=labelMarginY;
        labelframe.origin.x = frameMarginX;
        
        CGRect expandframe = self.expandButton.frame;
        expandframe.origin.y=buttonMarginY;
        
        CGRect webframe=self.webView.frame;
        webframe.origin.y=frameMarginY;
        webframe.origin.x=frameMarginX;
        webframe.size.width = [UIScreen mainScreen].bounds.size.width - 2*frameMarginX;
        webframe.size.height = [UIScreen mainScreen].bounds.size.height - self.musicLabel.frame.size.height - self.musicSettingTitleLabel.frame.size.height;
        
        [UIView animateWithDuration:0.5 animations:^{ 
            
            self.webView.frame=webframe;
            self.expandButton.frame = expandframe;
            self.musicLabel.frame = labelframe;
            [self.expandButton setTitle:NSLS(@"kExpand") forState:UIControlStateNormal];
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return  40.0f;
//}

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
    if ([[MusicItemManager defaultManager] isCurrentMusic:downloadItem]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) { 
        MusicItem *item = [_musicList objectAtIndex:indexPath.row];
        NSMutableArray *mutableDataList = [NSMutableArray arrayWithArray:_musicList];
        [mutableDataList removeObjectAtIndex:indexPath.row];
        _musicList = mutableDataList;
        
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[MusicItemManager defaultManager] deleteItem:item];

    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_canDelete == YES) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MusicSettingCell *cell = (MusicSettingCell*)[tableView cellForRowAtIndexPath:indexPath];
    [[MusicItemManager defaultManager] selectCurrentMusicItem:cell.musicItem];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // forbid popup call out window
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
}

@end
