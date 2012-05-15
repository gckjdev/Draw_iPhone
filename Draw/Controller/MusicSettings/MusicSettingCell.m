//
//  MusicSettingCell.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicSettingCell.h"
#import "MusicItemManager.h"

@implementation MusicSettingCell

@synthesize musicNameLabel;
@synthesize downloadProgress;
@synthesize selectedCurrentButton;
@synthesize musicItem = _musicItem;

+ (MusicSettingCell*) createCell:(id)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MusicSettingCell" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <MusicSettingCell> but cannot find cell object from Nib");
        return nil;
    }
    
    MusicSettingCell* cell = (MusicSettingCell*)[topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;

}

- (void)setCellInfoWithItem:(MusicItem*)item indexPath:(NSIndexPath*)indexPath
{
    _musicItem = item;
    self.musicNameLabel.text = item.fileName;
    self.downloadProgress.progress = [item.downloadProgress floatValue];
    self.selectedCurrentButton.selected = [[MusicItemManager defaultManager] currentMusicItem] == item;
}

- (IBAction)selectCurrent:(id)sender
{
    [[MusicItemManager defaultManager] setCurrentMusicItem:_musicItem];
}

@end
