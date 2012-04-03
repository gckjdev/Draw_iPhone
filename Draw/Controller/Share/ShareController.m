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
    [super dealloc];
}

- (void)loadAllPaints
{
    [self.paints removeAllObjects];
    [self.paints setArray:[[MyPaintManager defaultManager] findAllPaints]];
}

- (void)loadMyPaints
{
    [self.paints removeAllObjects];
    [self.paints setArray:[[MyPaintManager defaultManager] findOnlyMyPaints]];
}

- (void)selectImageAtIndex:(int)index
{
    _currentSelectedPaint = index;
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

#define BACK_GROUND_TAG 120120403
#define REPLAY_TAG  220120403
#define QUIT_BUTTON_TAG 320120403

- (void)quitReplay
{
    UIButton* btn = (UIButton*)[self.view viewWithTag:QUIT_BUTTON_TAG];
    ShowDrawView* view = (ShowDrawView*)[self.view viewWithTag:REPLAY_TAG];
    UIView* bck = [self.view viewWithTag:BACK_GROUND_TAG];
    [btn removeFromSuperview];
    [bck removeFromSuperview];
    [view removeFromSuperview];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SHARE: {
            MyPaint* myPaint = [self.paints objectAtIndex:_currentSelectedPaint];
            NSData* imageData = [NSData dataWithContentsOfFile:myPaint.image];
            UIImage* myImage = [UIImage imageWithData:imageData];
            ShareEditController* controller = [[ShareEditController alloc] initWithImage:myImage];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
        }
            break;
        case REPLAY: {
            MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
            NSData* currentData = [NSKeyedUnarchiver unarchiveObjectWithData:currentPaint.data ];
            NSArray* drawActionList = (NSArray*)currentData;
            
            UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            background.tag = BACK_GROUND_TAG;
            [background setBackgroundColor:[UIColor blackColor]];
            [background setAlpha:0.5];
            [self.view addSubview:background];
            [background release];
            
            ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(0, 75, 320, 330)];    
            replayView.tag = REPLAY_TAG;
            [self.view addSubview:replayView];
            [replayView release];            
            NSMutableArray *actionList = [NSMutableArray arrayWithArray:drawActionList];
            [replayView setDrawActionList:actionList];
            [replayView play];
            
            UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            [quit addTarget:self action:@selector(quitReplay) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:quit];
            [quit setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
            quit.tag = QUIT_BUTTON_TAG;
 
        }
            break;
        case DELETE: {
            MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
            BOOL result = [[MyPaintManager defaultManager] deleteMyPaints:currentPaint];
            if (result && [[NSFileManager defaultManager] fileExistsAtPath:currentPaint.image]) {
                [[NSFileManager defaultManager] removeItemAtPath:currentPaint.image error:nil];
            }
            [self.paints removeObjectAtIndex:_currentSelectedPaint];
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
    NSLog(@"total paints is %d", self.paints.count);
    return self.paints.count/IMAGES_PER_LINE +1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareCell* cell = [tableView dequeueReusableCellWithIdentifier:[ShareCell getIdentifier]];
    if (cell == nil) {
        cell = [ShareCell creatShareCellWithIndexPath:indexPath delegate:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableArray* imageArray = [[NSMutableArray alloc] init];
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        if (paintIndex < self.paints.count) {
            MyPaint* paint  = [self.paints objectAtIndex:paintIndex];
            NSString* paintName = [paint image];
            UIImage* image = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:paintName]) {
                NSData* data = [[NSData alloc] initWithContentsOfFile:paintName];
                image = [UIImage imageWithData:data];
                [data release];
                [imageArray addObject:image];
            }
            
        }
    }
    cell.indexPath = indexPath;
    [cell setImagesWithArray:imageArray];
    [imageArray release];
    return cell;
}

- (IBAction)changeGalleryFielter:(id)sender
{
    if (self.paintsFilter.selectedSegmentIndex == 0) {
        [self loadAllPaints];
        [self.gallery reloadData];
    } else {
        [self loadMyPaints];
        [self.gallery reloadData];
    }
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_paints setArray:[[MyPaintManager defaultManager] findAllPaints]];
    NSLog(@"get all paints, paints count is %d", _paints.count);

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
