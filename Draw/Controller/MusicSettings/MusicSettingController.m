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

#define MUSIC_URL @"http://m.easou.com/"

@implementation MusicSettingController

@synthesize tableView = _tableView;
@synthesize webView = _webView;
@synthesize editButton;
@synthesize musicList = _musicList;
@synthesize request;
@synthesize openURLForAction;
@synthesize urlForAction;

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
    [self showActivityWithText:NSLS(@"kLoadingURL")];
    
    NSLog(@"url = %@",URLString);
    
    NSURL *url = [NSURL URLWithString:URLString];
    request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openURL:MUSIC_URL];
    
    self.musicList = [MusicDownloadService findAllItems];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgressTimer) userInfo:nil repeats:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadData];
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
    return  30.0f;
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
    [_musicList objectAtIndex:indexPath.row];
    NSMutableArray *mutableDataList = [NSMutableArray arrayWithArray:_musicList];
    [mutableDataList removeObjectAtIndex:indexPath.row];
    _musicList = mutableDataList;
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - webView delegate method
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
    
    NSLog(@"Loading URL = %@", [[requestURL URL] absoluteURL]); 

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
