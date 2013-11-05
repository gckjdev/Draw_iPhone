//
//  SongSearchController.m
//  Draw
//
//  Created by 王 小涛 on 13-10-23.
//
//

#import "SongSearchController.h"
#import "SongService.h"
#import "SongCell.h"
#import "StringUtil.h"

@interface SongSearchController ()<UITextFieldDelegate>

@property (retain, nonatomic) NSArray *songs;
@property (retain, nonatomic) SingOpus *singOpus;

@end

@implementation SongSearchController


- (void)dealloc {
    [_searchTextField release];
    [_songs release];
    [_singOpus release];
    [super dealloc];
}

- (id)initWithSingOpus:(SingOpus *)opus{
    
    if (self = [super init]) {
        self.singOpus = opus;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTitle:NSLS(@"kSearchSong")];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBackButton:)];
    [v hideBackButton];
    
    [v setRightButtonTitle:NSLS(@"kClose")];
    [v setRightButtonSelector:@selector(clickBackButton:)];
    
    SET_INPUT_VIEW_STYLE(self.searchTextField);
    
    self.searchTextField.placeholder = NSLS(@"kInputSongNameForSearch");
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.delegate = self;
}

SET_CELL_BG_IN_CONTROLLER;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.
{
    [self clickSearchButton:nil];
    return YES;
}

- (IBAction)clickSearchButton:(id)sender {
    
    NSString *searchKey = [self.searchTextField.text stringByTrimmingBlankCharactersAtBothEnds];
    [self.searchTextField resignFirstResponder];

    if ([searchKey length] <= 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSongNameCannotBeBlank") delayTime:1.5];
        return;
    }

    [self showActivityWithText:NSLS(@"kLoading")];
    [[SongService defaultService] searchSongWithName:searchKey completed:^(int resultCode, NSArray *songs) {
        
        [self hideActivity];
        if (resultCode == 0) {
            self.songs = songs;
            [self.dataTableView reloadData];
            
            if ([self.songs count] == 0) {
                [self showTipsOnTableView:NSLS(@"kNoData")];
            }else{
                [self hideTipsOnTableView];
            }
        }else{
            [self showTipsOnTableView:NSLS(@"kLoadFailed")];
        }
    }];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.songs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [SongCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SongCell createCell:self];
    }
    
    [cell setCellData:[self.songs objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)didSelectSong:(PBSong *)song{
    
    [self.singOpus setSong:song];
    [self.singOpus setName:song.name];

    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_SELECT_SONG object:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)clickBackButton:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
