//
//  CommonSearchImageController.m
//  Draw
//
//  Created by Kira on 13-6-1.
//
//

#import "CommonSearchImageController.h"
#import "UIImageView+WebCache.h"
#import "ImageSearch.h"
#import "ImageSearchResult.h"
#import "GoogleCustomSearchService.h"

@interface CommonSearchImageController () {
    ImageSearch* _imageSearcher;
}

@end

@implementation CommonSearchImageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _imageSearcher = [[ImageSearch alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IMAGE_PER_LINE 3
#define IMAGE_HEIGHT  80
#define RESULT_IMAGE_TAG_OFFSET 20130601

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}
#pragma mark tab controller delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] init] autorelease];
        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
            UIImageView* imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)] autorelease];
            imageView.tag = RESULT_IMAGE_TAG_OFFSET + i;
            [cell addSubview:imageView];
        }
    }
    for (int i = 0; i < IMAGE_PER_LINE; i ++) {
        UIImageView* imageView = (UIImageView*)[cell viewWithTag:RESULT_IMAGE_TAG_OFFSET+i];
        if (self.dataList.count > IMAGE_PER_LINE*indexPath.row+i) {
            ImageSearchResult* result = (ImageSearchResult*)[self.dataList objectAtIndex:IMAGE_PER_LINE*indexPath.row+i];
            PPDebug(@"get search result %@", result);
            [imageView setImageWithURL:[NSURL URLWithString:result.url]];
        }
        
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    self.dataList = [GoogleCustomSearchService searchImageBytext:searchBar.text imageSize:CGSizeMake(0, 0) imageType:nil];
    self.dataList = [_imageSearcher searchImageBySize:CGSizeMake(0, 0) searchText:searchBar.text location:nil searchSite:nil startPage:0 maxResult:100];
    [self.dataTableView reloadData];
    [searchBar resignFirstResponder];
}


@end
