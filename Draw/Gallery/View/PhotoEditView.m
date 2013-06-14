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

@interface PhotoEditView ()

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *inputNameLabel;
@property (retain, nonatomic) PBUserPhoto* photo;

@property (retain, nonatomic) IBOutlet UITableView *tagTable;
@property (retain, nonatomic) NSMutableSet* tagSet;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//+ (PhotoEditView*)createViewWithTagPackageArray:(NSArray*)packageArray
//                                                    tagArray:(NSSet*)tagSet
//                                                    imageUrl:(NSString*)url
//                                                    delegate:(id<PhotoEditViewDelegate>)delegate
//{
//    PhotoEditView* view = [self createView];
//    view.tagPackageArray = packageArray;
//    view.delegate = delegate;
//    view.tagSet = tagSet;
//    view.tagTable.delegate = view;
//    view.tagTable.dataSource = view;
//    view.nameTextField.delegate = view;
//    view.imageUrl = url;
//    return view;
//}

+ (PhotoEditView*)createViewWithPhoto:(PBUserPhoto*)photo
                             editName:(BOOL)editName
                          resultBlock:(PhotoEditResultBLock)resultBlock
{
    PhotoEditView* view = [self createView];
    [view initWithPhoto:photo editName:editName];
    view.resultBlock = resultBlock;
    view.tagTable.dataSource = view;
    view.tagTable.delegate = view;
    view.nameTextField.delegate = view;
    return view;
}

- (void)initWithPhoto:(PBUserPhoto*)photo
             editName:(BOOL)editName
{
    [self initView:editName];
    if (photo) {
        self.tagSet = [[[NSMutableSet alloc] initWithArray:photo.tagsList] autorelease];
        [self.nameTextField setText:photo.name];
    }
    [self.tagTable reloadData];
    
}

- (void)initView:(BOOL)editName
{
    if (!editName) {
        [self.nameTextField setHidden:YES];
        [self.inputNameLabel setHidden:YES];
        [self.titleLabel setText:NSLS(@"kSetTag")];
        [self.tagTable setFrame:CGRectMake(self.tagTable.frame.origin.x, self.titleLabel.frame.origin.y, self.tagTable.frame.size.width, (self.tagTable.frame.size.height+ self.titleLabel.frame.size.height))];
    }

    self.tagPackageArray = [[PhotoTagManager defaultManager] tagPackageArray];
    [self.tagTable reloadData];
    
}


#define TAG_BTN_OFFSET 20130608
#define TITLE_TAG 120130608

#define SEPX    10
#define SEPY    5

#define ITEM_PER_LINE   4
#define LINE_PER_CELL   2

#define CELL_HEIGHT   100

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagPackageArray.count;
//    return self.tagPaceekageArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        float itemWidth = tableView.frame.size.width/ITEM_PER_LINE - SEPX;
        float itemHeight = CELL_HEIGHT/LINE_PER_CELL-SEPY;
        
        UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SEPX/2, SEPY/2, itemWidth, itemHeight)] autorelease];
        titleLabel.tag = TITLE_TAG;
        
        for (int i = 0; i <( LINE_PER_CELL*(ITEM_PER_LINE-1)); i ++) {
            float orgX = (tableView.frame.size.width/ITEM_PER_LINE)*(i%(ITEM_PER_LINE-1)+1)+SEPX/2;
            float orgY = (i/(ITEM_PER_LINE-1))*(CELL_HEIGHT/LINE_PER_CELL)+SEPY/2;
            UIButton* btn = [[[UIButton alloc] initWithFrame:CGRectMake(orgX, orgY, itemWidth, itemHeight)] autorelease];
            btn.tag = TAG_BTN_OFFSET + i;
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn addTarget:self action:@selector(clickTagBtn:) forControlEvents:UIControlEventTouchUpInside];
//            PPDebug(@"add tag btn, tag = %d, btn frame = (%.2f, %.2f, %.2f%.2f)",btn.tag, btn.frame.origin.x, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
            
            [cell addSubview:btn];
        }
        
        [cell addSubview:titleLabel];
        
    }
    
    TagPackage* package = [self.tagPackageArray objectAtIndex:indexPath.row];
    
    [self updateCell:cell forTagPackage:package];
    return cell;
}

- (void)updateCell:(UITableViewCell*)cell
     forTagPackage:(TagPackage*)package
{
    UILabel* titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
    [titleLabel setText:package.tagPackageName];
    
    for (int i = 0; i < package.tagArray.count; i ++) {
        NSString* photoTag = [package.tagArray objectAtIndex:i];
        UIButton* btn = (UIButton*)[cell viewWithTag:TAG_BTN_OFFSET + i];
        [btn setTitle:photoTag forState:UIControlStateNormal];
        if ([self.tagSet containsObject:photoTag]) {
            [btn setSelected:YES];
        }
//        if (!btn) {
//            PPDebug(@"find btn err");
//        }
//        PPDebug(@"<test>add tag <%@> for btn %d", [package.tagArray objectAtIndex:i], i);
//        PPDebug(@"update tag btn, tag = %d, btn frame = (%.2f, %.2f, %.2f%.2f)",btn.tag, btn.frame.origin.x, btn.frame.origin.y, btn.frame.size.width, btn.frame.size.height);
    }
}

- (IBAction)clickConfirm:(id)sender
{
//    if (_delegate && [_delegate respondsToSelector:@selector(didEditPictureInfo:name:imageUrl:)]) {
//        [_delegate didEditPictureInfo:self.tagSet name:self.nameTextField.text imageUrl:self.imageUrl];
//    }
    EXECUTE_BLOCK(_resultBlock, self.nameTextField.text, self.tagSet);
    self.resultBlock = nil;
    [self disappear];
}

- (IBAction)clickCancel:(id)sender
{
    [self disappear];
}

- (IBAction)clickTagBtn:(id)sender
{
    if (!_tagSet) {
        self.tagSet = [[[NSMutableSet alloc] init] autorelease];
    }
    UIButton* btn = (UIButton*)sender;
    if (!btn.selected) {
        [btn setSelected:YES];
        [self.tagSet addObject:btn.titleLabel.text];
    } else {
        [btn setSelected:NO];
        [self.tagSet removeObject:btn.titleLabel.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameTextField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [_photo release];
    [_tagSet release];
    [_tagPackageArray release];
    [_nameTextField release];
    [_titleLabel release];
    [_inputNameLabel release];
    RELEASE_BLOCK(_resultBlock);
    [super dealloc];
}
@end
