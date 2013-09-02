//
//  PhotoEditView.m
//  Draw
//
//  Created by Kira on 13-6-6.
//
//

#import "PhotoEditView.h"
#import "AutoCreateViewByXib.h"
#import "Photo.pb.h"
#import "TagPackage.h"
#import "PhotoTagManager.h"
#import "CommonImageManager.h"
#import "EditTagCell.h"

@interface PhotoEditView ()

@property (retain, nonatomic) PBUserPhoto* photo;
@property (retain, nonatomic) IBOutlet UITableView *tagTable;
@property (retain, nonatomic) NSArray* tagPackageArray;

@end

@implementation PhotoEditView

AUTO_CREATE_VIEW_BY_XIB(PhotoEditView)

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


+ (PhotoEditView*)createViewWithPhoto:(PBUserPhoto*)photo
{
    PhotoEditView* view = [self createView];
    [view initWithPhoto:photo];
    view.tagTable.dataSource = view;
    view.tagTable.delegate = view;
    return view;
}

- (void)initWithPhoto:(PBUserPhoto*)photo
{
    [self initView];
    if (photo) {
        self.tagSet = [[[NSMutableSet alloc] initWithArray:photo.tagsList] autorelease];
        
    }
    [self.tagTable reloadData];
    
}

- (void)initView
{
    self.tagPackageArray = [[PhotoTagManager defaultManager] tagPackageArray];
    [self.tagTable reloadData];
    
}


#define TAG_BTN_OFFSET 20130608
#define TITLE_TAG 120130608

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EditTagCell getCellHeight];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagPackageArray.count;
}

#pragma mark - tableView delegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditTagCell* cell = [tableView dequeueReusableCellWithIdentifier:[EditTagCell getCellIdentifier]];
    if (cell == nil) {
        cell = [EditTagCell createCell:nil];
    }
    
    TagPackage* package = [self.tagPackageArray objectAtIndex:indexPath.row];
    
    [self updateCell:cell forTagPackage:package];
    return cell;
}

#define MAX_TAG_COUNT   6
- (void)updateCell:(EditTagCell*)cell
     forTagPackage:(TagPackage*)package
{
    UIButton* titleLabel = (UIButton*)[cell viewWithTag:TITLE_TAG];
    [titleLabel setTitle:package.tagPackageName forState:UIControlStateNormal];
    
    for (int i = 0; i < MAX_TAG_COUNT; i ++) {
        UIButton* btn = (UIButton*)[cell viewWithTag:TAG_BTN_OFFSET + i];
        [btn setHidden:YES];
        if (i < package.tagArray.count) {
            NSString* photoTag = [package.tagArray objectAtIndex:i];
            
            [btn setTitle:photoTag forState:UIControlStateNormal];
            if ([self.tagSet containsObject:photoTag]) {
                [btn setSelected:YES];
            }
            [btn addTarget:self action:@selector(clickTagBtn:) forControlEvents:UIControlEventTouchUpInside];
            [btn setHidden:NO];
        }
    }
}



- (void)reset
{
    [self.tagSet removeAllObjects];
    [self.tagTable reloadData];
}

- (IBAction)clickTagBtn:(id)sender
{
    if (!_tagSet) {
        self.tagSet = [[[NSMutableSet alloc] init] autorelease];
    }
    UIButton* btn = (UIButton*)sender;
    if (!btn.selected) {
        [btn setSelected:YES];
        if (btn.titleLabel.text && btn.titleLabel.text.length > 0) {
            [self.tagSet addObject:btn.titleLabel.text];
        }
    
    } else {
        [btn setSelected:NO];
        if (btn.titleLabel.text && btn.titleLabel.text.length > 0) {
            [self.tagSet removeObject:btn.titleLabel.text];
        }
        
    }
}


- (void)dealloc {
    [_photo release];
    [_tagSet release];
    [_tagPackageArray release];
    [super dealloc];
}
@end
