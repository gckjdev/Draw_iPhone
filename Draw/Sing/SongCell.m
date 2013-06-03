//
//  SongCell.m
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import "SongCell.h"
#import "AutoCreateViewByXib.h"

@implementation SongCell

AUTO_CREATE_VIEW_BY_XIB(SongCell);

+ (NSString*)getCellIdentifier{
    return @"SongCell";
}

+ (CGFloat)getCellHeight{
    return 21;
}

- (void)setCellData:(PBSong *)song{
    self.nameLabel.text = song.name;
}


- (void)dealloc {
    [_nameLabel release];
    [super dealloc];
}
@end
