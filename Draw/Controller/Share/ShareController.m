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
#import "ShareCell.h"
#import "ShareImageManager.h"
#import "UserManager.h"
#import "ReplayController.h"
#import "GifView.h"


#define BUTTON_INDEX_OFFSET 20120229
#define IMAGE_WIDTH 93

#define IMAGE_OPTION            20120407
#define SHARE_IMAGE_OPTION      120120407
#define SHARE_AS_PHOTO_OPTION   220120407

@interface ShareController ()

@end

@implementation ShareController
@synthesize paintsFilter;
@synthesize gallery;
@synthesize paints = _paints;
@synthesize titleLabel;
@synthesize shareAction = _shareAction;
@synthesize noDrawingLabel;

- (void)dealloc {
    [noDrawingLabel release];
    [_shareAction release];
    [paintsFilter release];
    [gallery release];
    [_paints release];
    [titleLabel release];
    [_gifImages release];
    [super dealloc];
}

- (void)refleshGallery
{
    [self loadPaintsOnlyMine:self.paintsFilter.isSelected];
    [self.gallery reloadData];
}

- (void)loadPaintsOnlyMine:(BOOL)onlyMine
{
    if (onlyMine) {
        self.paints = [[MyPaintManager defaultManager] findOnlyMyPaints];
    } else {
        self.paints = [[MyPaintManager defaultManager] findAllPaints];
    }
    
    if ([self.paints count] > 0){
        self.noDrawingLabel.text = NSLS(@"");
        self.noDrawingLabel.hidden = YES;
    }
    else{
        self.noDrawingLabel.text = NSLS(@"kNoDrawings");
        self.noDrawingLabel.hidden = NO;        
    }
}

- (void)selectImageAtIndex:(int)index
{
    _currentSelectedPaint = index;
    UIActionSheet* tips = nil;
    
    if ([LocaleUtils isChina]){
        tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                                      delegate:self 
                                             cancelButtonTitle:NSLS(@"kCancel") 
                                        destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                             otherButtonTitles:NSLS(@"kShareAsGif"),
                                                    NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
    }
    else{
        tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                           delegate:self 
                                  cancelButtonTitle:NSLS(@"kCancel") 
                             destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                  otherButtonTitles:NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
        
    }
    tips.tag = IMAGE_OPTION;
    [tips showInView:self.view];
    [tips release];
    
}

#pragma mark - UIActionSheetDelegate

- (void)showViewController:(UIViewController*)controller
{
    [self.navigationController presentModalViewController:controller animated:YES];
}


#define SHARE_GIF_DRAW_VIEW_TAG 20120409
- (void)shareAsGif
{
    [_gifImages removeAllObjects];
    
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    ReplayController* replayController = [[ReplayController alloc] initWithPaint:currentPaint];
    [replayController setReplayForCreateGif:YES];    
    [self.navigationController pushViewController:replayController animated:YES];
    [replayController release];        
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    
    if (buttonIndex == SHARE_AS_PHOTO) {                        
        self.shareAction = [[[ShareAction alloc] initWithDrawImageFile:currentPaint.image 
                                                                 isGIF:NO
                                                             drawWord:currentPaint.drawWord
                                                                 isMe:[currentPaint.drawByMe boolValue]] autorelease];
            
        [_shareAction displayWithViewController:self];                       
    }                            
    else if (buttonIndex == SHARE_AS_GIF)
    {
        [self shareAsGif];
    }
    else if (buttonIndex == REPLAY){                                        
        ReplayController* replayController = [[ReplayController alloc] initWithPaint:currentPaint];
        [self.navigationController pushViewController:replayController animated:YES];
        [replayController release];            
    }
    else if (buttonIndex ==  DELETE) {
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") 
                                                           message:NSLS(@"kAre_you_sure") 
                                                             style:CommonDialogStyleDoubleButton 
                                                         deelegate:self];            
        [dialog showInView:self.view];
    }
    
}


#pragma mark - Common Dialog Delegate
- (void)clickOk:(CommonDialog *)dialog
{
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    [[MyPaintManager defaultManager] deleteMyPaints:currentPaint];
    [self refleshGallery];
}

- (void)clickBack:(CommonDialog *)dialog
{
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"total paints is %d", self.paints.count);
    
    int number = 0;
    if (self.paints.count % IMAGES_PER_LINE == 0){
        number = self.paints.count / IMAGES_PER_LINE;
    }
    else{
        number = self.paints.count / IMAGES_PER_LINE + 1;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAutoreleasePool* loopPool = [[NSAutoreleasePool alloc] init];
    ShareCell* cell = [tableView dequeueReusableCellWithIdentifier:[ShareCell getIdentifier]];
    if (cell == nil) {
        cell = [ShareCell creatShareCellWithIndexPath:indexPath delegate:self];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableArray* myPaintArray = [[NSMutableArray alloc] init];
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        if (paintIndex < self.paints.count) {
            MyPaint* paint  = [self.paints objectAtIndex:paintIndex];
            
//            NSString* paintName = [paint image];
//            UIImage* image = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:paint.image]) {
                [myPaintArray addObject:paint];
//                NSData* data = [[NSData alloc] initWithContentsOfFile:paintName];
//                image = [UIImage imageWithData:data];
//                [data release];
//                [imageArray addObject:image];
            }
        }
    }
    cell.indexPath = indexPath;
    [cell setImagesWithArray:myPaintArray];
    [myPaintArray release];
    [loopPool release];
    return cell;
}

- (IBAction)changeGalleryFielter:(id)sender
{
    if ([self.paintsFilter isSelected]) {
        [self.paintsFilter setSelected:NO];
    } else {
        [self.paintsFilter setSelected:YES];
    }
    [self refleshGallery];
}

-(IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _paints = [[NSMutableArray alloc] init];
        _gifImages = [[NSMutableArray alloc] init];

        if ([LocaleUtils isChina]){
            int index = 0;
            SHARE_AS_PHOTO = index++;
            SHARE_AS_GIF = index++;
            REPLAY = index++;
            DELETE = index++;
            CANCEL = index++;
        }
        else{
            int index = 0;
            SHARE_AS_PHOTO = index++;
            REPLAY = index++;
            DELETE = index++;
            CANCEL = index++;            
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];  
    [self refleshGallery];
    
    NSLog(@"get all paints, paints count is %d", _paints.count);

    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLS(@"kShareTitle");

}

- (void)viewDidUnload
{
    [self setPaintsFilter:nil];
    [self setGallery:nil];
    [self setPaints:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
