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

@interface SongSearchController ()

@property (retain, nonatomic) NSArray *songs;

@end

@implementation SongSearchController


- (void)dealloc {
    [_searchTextField release];
    [_songs release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SET_INPUT_VIEW_STYLE(self.searchTextField);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

- (IBAction)clickSearchButton:(id)sender {
    
    NSString *searchKey = self.searchTextField.text;
    
    [[SongService defaultService] searchSongWithName:searchKey completed:^(int resultCode, NSArray *songs) {
        
        self.songs = songs;
        [self.dataTableView reloadData];
    }];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SongCell createCell:self];
    }
    
    [cell setCellData:[self.songs objectAtIndex:indexPath.row]];
}

- (void)didSelectSong:(PBSong *)song{
    
    
}

@end
