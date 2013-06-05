//
//  SongCell.h
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import "PPTableViewCell.h"
#import "Sing.pb.h"

@interface SongCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

- (void)setCellData:(PBSong *)song;

@end
