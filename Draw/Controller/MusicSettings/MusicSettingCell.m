//
//  MusicSettingCell.m
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicSettingCell.h"

@implementation MusicSettingCell

@synthesize musicNameLabel;
@synthesize downloadProgress;

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
    self.musicNameLabel.text = item.musicName;
    self.downloadProgress.progress = [item.downloadProgress floatValue];
}


@end
