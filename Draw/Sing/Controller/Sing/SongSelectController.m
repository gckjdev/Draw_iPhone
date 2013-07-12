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
#import "InputDialog.h"
#import "StringUtil.h"
#import "SongTagCell.h"

#define CELL_COUNT 5

@interface SongSelectController(){
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
    self.tag = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SONG_CATEGORY_TAG];

    [[SongService defaultService] setDelegate:self];
    [[SongService defaultService] randomSongsWithTag:_tag count:CELL_COUNT];
    [self showActivityWithText:NSLS(@"kLoading")];
//    self.songs = [[SongManager defaultManager] randomSongsWithCount:CELL_COUNT];
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
    [self showActivityWithText:NSLS(@"kLoading")];
}

- (IBAction)clickSelfDefineButton:(id)sender {
    
    PPDebug(@"clickSelfDefine");
    InputDialog *dialog = [InputDialog dialogWith:NSLS(@"kInputSingName") clickOK:^(NSString *inputStr) {
        
        if ([inputStr isBlank]) {
            [self popupUnhappyMessage:NSLS(@"kSingNameCannotBeBlankStr") title:nil];
            return;
        }
        
        SingController *vc = [[[SingController alloc] initWithName:inputStr] autorelease];
        [self.navigationController pushViewController:vc animated:YES];
        
    } clickCancel:^(NSString *inputStr) {
        
    }];
    
    [dialog showInView:self.view];
}

- (IBAction)clickCategoryButton:(id)sender {
    
    self.categoryView = [SongCategoryView createCategoryView];
    _categoryView.delegate = self;
    [_categoryView showInView:self.view];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (void)didSelectTag:(NSString *)tag{
    
    PPDebug(@"click tag: %@", tag);
    self.tag = tag;
    [[SongService defaultService] randomSongsWithTag:_tag count:CELL_COUNT];
    
    [self showActivityWithText:NSLS(@"kLoading")];
}

- (void)didGetSongs:(int)resultCode songs:(NSArray *)songs{
    
    [self hideActivity];
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
