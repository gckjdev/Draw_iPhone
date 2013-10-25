//
//  SearchPostController.m
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "SearchPostController.h"
#import "BBSViewManager.h"
#import "BBSPostDetailController.h"
#import "BBSPostCell.h"

@interface SearchPostController ()

@end

#define TAB_ID 100

@implementation SearchPostController

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
    [self setPullRefreshType:PullRefreshTypeNone];
    [super viewDidLoad];
    [BBSViewManager updateDefaultTitleLabel:self.titleLabel text:NSLS(@"kSearch")];
    SET_INPUT_VIEW_STYLE(self.searchTextField);
    [self.searchTextField becomeFirstResponder];
    self.searchTextField.text = nil;
    [self.searchTextField setPlaceholder:NSLS(@"kBBSSearchPlaceholder")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_searchTextField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [super viewDidUnload];
}
- (IBAction)clickSearchButton:(id)sender {
    if ([self.searchTextField.text length] != 0) {
        [self reloadTableViewDataSource];
    }
}

- (IBAction)didKeyWordChanged:(id)sender {
    PPDebug(@"<didKeyWordChanged>, text = %@", self.searchTextField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSearchButton:nil];
    return YES;
}

- (UIControl *)maskView
{
#define MASK_VIEW_TAG 112233
    
    UIControl *mask = (id)[self.view viewWithTag:MASK_VIEW_TAG];
    if (mask == nil) {
        mask = [[[UIControl alloc] initWithFrame:self.view.bounds] autorelease];
        [mask updateOriginY:CGRectGetMaxY(self.searchTextField.frame)];
        mask.backgroundColor = [UIColor blackColor];
        mask.alpha = 0.3;
        mask.tag = MASK_VIEW_TAG;
        [mask addTarget:self action:@selector(clickMaskView:) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:mask belowSubview:self.searchTextField];
    }
    return mask;
}

- (void)clickMaskView:(UIControl *)maskView
{
    [self.searchTextField resignFirstResponder];
    [[self maskView] setHidden:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [[self maskView] setHidden:NO];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [[self maskView] setHidden:YES];
}


#pragma mark - table view delegate
- (PBBBSPost *)postForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dList = self.tabDataList;
    if (indexPath.row >= [dList count]) {
        return nil;
    }
    PBBBSPost *post = [self.tabDataList objectAtIndex:indexPath.row];
    return post;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [self.tabDataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self.tabDataList objectAtIndex:indexPath.row];
	return [BBSPostCell getCellHeightWithBBSPost:post];
}


- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [BBSPostCell getCellIdentifier];
	BBSPostCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSPostCell createCell:self];
	}
    PBBBSPost *post = [self postForIndexPath:indexPath];
    [cell updateCellWithBBSPost:post];
    cell.backgroundColor = [UIColor clearColor];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBBBSPost *post = [self postForIndexPath:indexPath];
    [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                fromController:self
                                                      animated:YES];
}


- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 50;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return TAB_ID;
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    NSString *text = self.searchTextField.text;
    [self showActivityWithText:[NSString stringWithFormat:NSLS(@"kSearching")]];
    [self.searchTextField resignFirstResponder];
    [[self maskView] setHidden:YES];
    [[BBSService defaultService] searchPostListByKeyWord:text limit:50 hanlder:^(NSInteger resultCode, NSArray *postList, NSInteger tag) {
         [self hideActivity];
         if (resultCode == 0) {
             [self finishLoadDataForTabID:tabID resultList:postList];
         }else{
             [self failLoadDataForTabID:tabID];
         }        
    }];
}

@end
