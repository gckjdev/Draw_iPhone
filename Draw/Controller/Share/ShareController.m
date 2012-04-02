//
//  ShareController.m
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareController.h"
#import "LocaleUtils.h"
#import "ShareEditController.h"
#import "MyPaintManager.h"
#import "MyPaint.h"
#import "DrawAction.h"
//#import "DrawView.h"
#import "ShowDrawView.h"
#define BUTTON_INDEX_OFFSET 20120229
#define IMAGES_PER_LINE 3
#define IMAGE_WIDTH 93

@interface ShareController ()

@end

@implementation ShareController
@synthesize paintsFilter;
@synthesize gallery;
@synthesize paints = _paints;

- (void)dealloc {
    [paintsFilter release];
    [gallery release];
    [_paints release];
    [_selectedPaints release];
    [super dealloc];
}

- (void)popTipsWithIndex:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [_selectedPaints removeAllObjects];
    [_selectedPaints addObject:[self.paints objectAtIndex:btn.tag-BUTTON_INDEX_OFFSET]];
    _currentSelectedPaint = btn.tag-BUTTON_INDEX_OFFSET;
    UIActionSheet* tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"Options") delegate:self cancelButtonTitle:NSLS(@"Cancel") destructiveButtonTitle:NSLS(@"Share") otherButtonTitles:NSLS(@"Replay"), NSLS(@"Delete"), nil];
    [tips showInView:self.view];
    [tips release];
    
}

#pragma mark - UIActionSheetDelegate
enum {
    SHARE = 0,
    REPLAY,
    DELETE,
    CANCEL
};

- (void)quitReplay
{
    UIButton* btn = (UIButton*)[self.view viewWithTag:11111];
    ShowDrawView* view = (ShowDrawView*)[self.view viewWithTag:22222];
    UIView* bck = [self.view viewWithTag:33333];
    [btn removeFromSuperview];
    [bck removeFromSuperview];
    [view removeFromSuperview];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SHARE: {
            UIImage* myImage = [[_selectedPaints allObjects] objectAtIndex:0];
            ShareEditController* controller = [[ShareEditController alloc] initWithImage:myImage];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
            break;
        case REPLAY: {
            NSArray* allPaints = [[MyPaintManager defaultManager] findAllPaints];
            MyPaint* currentPaint = [allPaints objectAtIndex:_currentSelectedPaint];
            NSData* currentData = [NSKeyedUnarchiver unarchiveObjectWithData:currentPaint.data ];
            NSArray* drawActionList = (NSArray*)currentData;
            UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            [background setBackgroundColor:[UIColor blackColor]];
            [background setAlpha:0.5];
            ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(0, 75, 320, 330)];
            [self.view addSubview:background];
            [self.view addSubview:replayView];
            NSMutableArray *actionList = [NSMutableArray arrayWithArray:drawActionList];
            [replayView setDrawActionList:actionList];
            [replayView play];
            UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [quit addTarget:self action:@selector(quitReplay) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:quit];
            [quit setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
            quit.tag = 11111;
            replayView.tag = 22222;
            background.tag = 33333;
            [replayView release];
            [background release];
            
        }
            break;
        case DELETE: {
            for (UIImage* image in _selectedPaints) {
                [self.paints removeObject:image];
            }
            [self.gallery reloadData];
        }
            break;
        default:
            break;
    }
}

#pragma mark - table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"row is %d", self.paints.count/IMAGES_PER_LINE);
    return self.paints.count/IMAGES_PER_LINE +1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ShareControllerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ShareControllerCell"];
    }
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (paintIndex < self.paints.count) {
            UIImage* paint  = [self.paints objectAtIndex:paintIndex];
            if (paint) {
                UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(lineIndex*IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_WIDTH)];
                [btn setBackgroundImage:paint forState:UIControlStateNormal];
                btn.tag = BUTTON_INDEX_OFFSET+paintIndex;
                [btn addTarget:self action:@selector(popTipsWithIndex:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:btn];
                [btn release];
            }
        }
    }
    
    return cell;
}

- (IBAction)changeGalleryFielter:(id)sender
{
    NSLog(@"%d", self.paintsFilter.selectedSegmentIndex);
}

-(IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _paints = [[NSMutableArray alloc] init];
        _selectedPaints = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray* allPaints = [[MyPaintManager defaultManager] findAllPaints];
    for (MyPaint* paint in allPaints) {
        NSString* paintName = [paint image];
        if ([[NSFileManager defaultManager] fileExistsAtPath:paintName]) {            
            NSData* imageData = [[NSData alloc] initWithContentsOfFile:paintName];
            UIImage* image = [UIImage imageWithData:imageData];
            [self.paints addObject:image];         
        }
    }

    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPaintsFilter:nil];
    [self setGallery:nil];
    [self setPaints:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
