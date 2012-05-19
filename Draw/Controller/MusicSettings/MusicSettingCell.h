//
//  MusicSettingCell.h
//  Draw
//
//  Created by gckj on 12-5-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "MusicItem.h"

@interface MusicSettingCell : PPTableViewCell
{
    MusicItem* _musicItem;
}

@property (retain, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (retain, nonatomic) MusicItem *musicItem;

+ (MusicSettingCell*) createCell:(id)delegate;
- (void)setCellInfoWithItem:(MusicItem*)item indexPath:(NSIndexPath*)indexPath;

@end
