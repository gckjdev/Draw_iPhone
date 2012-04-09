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
#import "ShareGifController.h"
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

- (void)dealloc {
    [_shareAction release];
    [paintsFilter release];
    [gallery release];
    [_paints release];
    [titleLabel release];
    [_gifImages release];
    [super dealloc];
}

- (void)loadAllPaints
{
    self.paints = [[MyPaintManager defaultManager] findAllPaints];
}

- (void)loadMyPaints
{
    self.paints = [[MyPaintManager defaultManager] findOnlyMyPaints];
}

- (void)selectImageAtIndex:(int)index
{
    _currentSelectedPaint = index;
    UIActionSheet* tips = [[UIActionSheet alloc] initWithTitle:NSLS(@"kOptions") 
                                                      delegate:self 
                                             cancelButtonTitle:NSLS(@"kCancel") 
                                        destructiveButtonTitle:NSLS(@"kShareAsPhoto") 
                                             otherButtonTitles:NSLS(@"kShareAsGif"),
                                                    NSLS(@"kReplay"), NSLS(@"kDelete"), nil];
    tips.tag = IMAGE_OPTION;
    [tips showInView:self.view];
    [tips release];
    
}

#pragma mark - UIActionSheetDelegate
enum {
    SHARE_AS_PHOTO = 0,
    SHARE_AS_GIF,
    REPLAY,
    DELETE,
    CANCEL
};
enum {
    SHARE_PNG = 0,
    SHARE_GIF
};

#define BACK_GROUND_TAG 120120403
#define REPLAY_TAG  220120403
#define QUIT_BUTTON_TAG 320120403
#define CREATE_GIF_BUTTON_TAG 20120404

- (void)quitReplay
{
    UIView* bck = [self.view viewWithTag:BACK_GROUND_TAG];
    UIButton* btn = (UIButton*)[self.view viewWithTag:QUIT_BUTTON_TAG];
    [bck removeFromSuperview];
    [btn removeFromSuperview];
}




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
    
    /*
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    NSData* currentData = [NSKeyedUnarchiver unarchiveObjectWithData:currentPaint.data ];
    NSArray* drawActionList = (NSArray*)currentData;
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [background setImage:[UIImage imageNamed:@"wood_bg.png"]];
    background.tag = BACK_GROUND_TAG;
    UIImageView* paper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    [paper setImage:[UIImage imageNamed:@"paper.png"]];
    [background addSubview:paper];
    
    ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(10, 15, 300, 370)];    
    replayView.tag = REPLAY_TAG;
    [background addSubview:replayView];
    [replayView release];            

    NSMutableArray *gifActionList = [DrawAction 
                                     getTheLastActionListWithoutClean:drawActionList];
    
    [replayView setDrawActionList:gifActionList];
    replayView.delegate = self;
    replayView.playSpeed = 0.01;
    
    [replayView play];
    
    [self.view addSubview:background];
    [background release];
    
    UIImageView* paperClip = [[UIImageView alloc] initWithFrame:CGRectMake(53, -2, 194, 40)];
    [paperClip setImage:[UIImage imageNamed:@"paperclip.png"]];
    [background addSubview:paperClip];
    
    UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(0, 410, 80, 40)];
    [quit setTitle:NSLS(@"kExit") forState:UIControlStateNormal];
    [quit addTarget:self action:@selector(quitReplay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quit];
    [quit setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
    quit.tag = QUIT_BUTTON_TAG;
    
    [self showActivityWithText:NSLS(@"kCreating_gif")];    
    */
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    
    if (actionSheet.tag == IMAGE_OPTION) {
        switch (buttonIndex) {
            case SHARE_AS_PHOTO: {
                
                
                self.shareAction = [[[ShareAction alloc] initWithDrawImageFile:currentPaint.image 
                                                                         isGIF:NO
                                                                     drawWord:currentPaint.drawWord
                                                                         isMe:[currentPaint.drawByMe boolValue]] autorelease];
                
                [_shareAction displayWithViewController:self];
                
                /*
                UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") 
                                                                          delegate:self 
                                                                 cancelButtonTitle:NSLS(@"kCancel") 
                                                            destructiveButtonTitle:NSLS(@"kSave_to_album") 
                                                                 otherButtonTitles:NSLS(@"kShare_via_Email"), 
//                                                                                NSLS(@"kShare_via_Sina_weibo"),
//                                                                                NSLS(@"kShare_via_tencent_weibo"),
//                                                                                NSLS(@"kShare_via_Facebook"),
                                                                                nil];

                if ([[UserManager defaultManager] hasBindSinaWeibo]){
                    [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
                }
                
                if ([[UserManager defaultManager] hasBindQQWeibo]){
                    [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
                }
                
                if ([[UserManager defaultManager] hasBindFacebook]){
                    [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Facebook")];
                }                
                
                shareOptions.tag = SHARE_AS_PHOTO_OPTION;
                [shareOptions showInView:self.view];
                [shareOptions release];
                 */
            }                            
                break;
            case SHARE_AS_GIF:
            {
                [self shareAsGif];
            }
                break;
                
            case REPLAY: {
                                
                
                ReplayController* replayController = [[ReplayController alloc] initWithPaint:currentPaint];
                [self.navigationController pushViewController:replayController animated:YES];
                [replayController release];
                
                /*
                NSData* currentData = [NSKeyedUnarchiver unarchiveObjectWithData:currentPaint.data ];
                NSArray* drawActionList = (NSArray*)currentData;
                
                UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
                [background setImage:[UIImage imageNamed:@"wood_bg.png"]];
                background.tag = BACK_GROUND_TAG;
                UIImageView* paper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
                [paper setImage:[UIImage imageNamed:@"paper.png"]];
                [background addSubview:paper];

                ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(10, 15, 300, 370)];    
                replayView.tag = REPLAY_TAG;
                [background addSubview:replayView];
                [replayView release];            
                NSMutableArray *actionList = [NSMutableArray arrayWithArray:drawActionList];
                [replayView setDrawActionList:actionList];
                [replayView play];
                [self.view addSubview:background];
                [background release];
                
                UIImageView* paperClip = [[UIImageView alloc] initWithFrame:CGRectMake(53, -2, 194, 40)];
                [paperClip setImage:[UIImage imageNamed:@"paperclip.png"]];
                [background addSubview:paperClip];
                
                UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(10, 410, 80, 40)];
                [quit setTitle:NSLS(@"Back") forState:UIControlStateNormal];
                [quit addTarget:self action:@selector(quitReplay) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:quit];
                [quit setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
                quit.tag = QUIT_BUTTON_TAG;
                 */
 
            }
                break;
                break;
            case DELETE: {
                CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSure_delete") message:NSLS(@"kAre_you_sure") style:CommonDialogStyleDoubleButton deelegate:self];
                [dialog showInView:self.view];
            }
                break;
            default:
                break;
        }
    }
    
//    if (actionSheet.tag == SHARE_AS_PHOTO_OPTION && buttonIndex != actionSheet.cancelButtonIndex) {                
//        switch (buttonIndex) {
//                
//            case SHARE_VIA_ALBUM:
//                // TODO save image to album
//                break;
//                
//            case SHARE_VIA_EMAIL:
//                // TODO send by email
//                break;
//                
//            default: 
//            {
//                MyPaint* myPaint = [self.paints objectAtIndex:_currentSelectedPaint];
//                NSData* imageData = [NSData dataWithContentsOfFile:myPaint.image];
//                UIImage* myImage = [UIImage imageWithData:imageData];
//                ShareEditController* controller = [[ShareEditController alloc] initWithImage:myImage];
//                [self.navigationController pushViewController:controller animated:YES];
//                [controller release];
//            } 
//                break;
//        }
//    }
    
}


#pragma mark - Show Draw View Delegate
#define COMPRESS_SCALE 0.6
#define POINT_COUNT_PER_FRAME 4
- (void)createImageAndSave:(ShowDrawView *)showView
{
    UIImage *image = [showView createImageWithScale:0.6];
    [_gifImages addObject:image];

}
- (void)didPlayDrawView:(ShowDrawView *)showDrawView AtActionIndex:(NSInteger)actionIndex pointIndex:(NSInteger)pointIndex
{
    NSInteger actionCount = [showDrawView.drawActionList count];

    if (showDrawView.tag == REPLAY_TAG) {
        if (actionIndex < actionCount && actionIndex >= 0) {
            DrawAction *action = [showDrawView.drawActionList objectAtIndex:actionIndex];
            NSInteger pointCount = [action pointCount];
            if (pointCount < 1) {
                return;
            }
            
            if (pointCount < POINT_COUNT_PER_FRAME) {
                if (pointIndex == pointCount - 1) {
                    [self createImageAndSave:showDrawView];
                    NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                }
                return;
            }
            
            if (pointIndex == pointCount - 1) 
            {
                NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                [self createImageAndSave:showDrawView];
            }else if((pointIndex % POINT_COUNT_PER_FRAME) == (POINT_COUNT_PER_FRAME - 1 ) && (pointIndex + POINT_COUNT_PER_FRAME / 2) < pointCount)
            {
                NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                [self createImageAndSave:showDrawView];
            }
        }

    }
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView;
{
    if (showDrawView.tag == REPLAY_TAG) {
        [self hideActivity];
        [self quitReplay];
        ShareGifController* controller = [[ShareGifController alloc] initWithGifFrames:_gifImages];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    
}




#pragma mark - Common Dialog Delegate
- (void)clickOk:(CommonDialog *)dialog
{
    MyPaint* currentPaint = [self.paints objectAtIndex:_currentSelectedPaint];
    [[MyPaintManager defaultManager] deleteMyPaints:currentPaint];
    [self changeGalleryFielter:nil];
    [self.gallery reloadData];
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self changeGalleryFielter:nil];
    
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
