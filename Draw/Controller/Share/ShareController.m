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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paints.count/IMAGES_PER_LINE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ShareControllerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ShareControllerCell"];
    }
    for (int lineIndex = 0; lineIndex < IMAGES_PER_LINE; lineIndex++) {
        int paintIndex = indexPath.row*IMAGES_PER_LINE + lineIndex;
        UIImage* paint  = [self.paints objectAtIndex:paintIndex];
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(lineIndex*IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_WIDTH)];
        [btn setBackgroundImage:paint forState:UIControlStateNormal];
        btn.tag = BUTTON_INDEX_OFFSET+paintIndex;
        [btn addTarget:self action:@selector(popTipsWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [btn release];
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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_paints == nil) {
        _paints = [[NSMutableArray alloc] init ];
    }
    if (_selectedPaints == nil) {
        _selectedPaints = [[NSMutableSet alloc] init];
            }
    for (int i = 0; i < 1000; i++) {
        if (i%2 == 0) {
            [_paints addObject:[[UIImage imageNamed:@"57.png"] copy]];
                } else {
                    [_paints addObject:[[UIImage imageNamed:@"default_avatar.jpg"]copy]];
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
