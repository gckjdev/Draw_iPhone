//
//  SongSelectController.m
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import "SongSelectController.h"
#import "SongManager.h"
#import "SongCell.h"
#import "SingController.h"
#import "OpusManager.h"
#import "SongCategoryView.h"

#define CELL_COUNT 5

@interface SongSelectController(){
    BOOL _isCategoryViewShow;
}

@property (retain, nonatomic) NSArray *songs;
@property (retain, nonatomic) SongCategoryView *categoryView;
@property (retain, nonatomic) NSString *tag;

@end

@implementation SongSelectController


- (void)dealloc {
    [_songs release];
    [_titleLabel release];
    [_categoryView release];
    [super dealloc];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [[SongService defaultService] setDelegate:self];
//    [[SongService defaultService] randomSongsWithTag:_tag count:CELL_COUNT];
    self.songs = [[SongManager defaultManager] randomSongsWithCount:CELL_COUNT];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_songs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SongCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [SongCell createCell:self];
    }
    
    PBSong *song = [_songs objectAtIndex:indexPath.row];
    [cell setCellData:song forIndex:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PBSong *song = [_songs objectAtIndex:indexPath.row];
    
    SingController *vc = [[[SingController alloc] initWithSong:song] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickChangeSongsButton:(id)sender {
    
    [[SongService defaultService] randomSongsWithTag:_tag count:CELL_COUNT];
}

- (IBAction)clickDraftButton:(id)sender {
//    SingOpus *opus = [[OpusManager singDraftOpusManager] opusWithOpusId:@"2"];
//    SingController *vc = [[[SingController alloc] initWithOpus:opus] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickCategoryButton:(id)sender {
    if (_categoryView == nil) {
        self.categoryView = [SongCategoryView createCategoryView];
        _categoryView.delegate = self;
        _isCategoryViewShow = NO;
    }
    
    if (_isCategoryViewShow) {
        [_categoryView dismiss];
        _isCategoryViewShow = NO;
    }else{
        [_categoryView showInView:self.view];
        _isCategoryViewShow = YES;
    }
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)didClickBgButton{
    [_categoryView dismiss];
    _isCategoryViewShow = NO;
}

- (void)didSelectTag:(NSString *)tag{
    [_categoryView dismiss];
    _isCategoryViewShow = NO;
    
    PPDebug(@"click tag: %@", tag);
    self.tag = tag;
    [[SongService defaultService] randomSongsWithTag:_tag count:CELL_COUNT];
}

- (void)didGetSongs:(int)resultCode songs:(NSArray *)songs{
    
    if (resultCode == 0) {
        [self hideTipsOnTableView];
        self.songs = songs;
        [self.dataTableView reloadData];
        
        if ([self.songs count] == 0) {
            [self showTipsOnTableView:NSLS(@"kNoData")];
        }
    }else{
        [self showTipsOnTableView:NSLS(@"kLoadFail")];
    }
}

@end
