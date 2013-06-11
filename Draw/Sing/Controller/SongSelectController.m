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

@interface SongSelectController()

@property (retain, nonatomic) NSArray *songs;

@end

@implementation SongSelectController


- (void)dealloc {
    [_songs release];
    [_titleLabel release];
    [super dealloc];
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.songs = [[SongManager defaultManager] randomSongsWithCount:5];
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
    
    self.songs = [[SongManager defaultManager] randomSongsWithCount:5];
    
    [self.dataTableView reloadData];
}

- (IBAction)clickDraftButton:(id)sender {
//    SingOpus *opus = [[OpusManager singOpusManager] opusWithOpusId:@"2"];
//    SingController *vc = [[[SingController alloc] initWithOpus:opus] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickCategoryButton:(id)sender {
    PPDebug(@"category");
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
