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
@property (retain, nonatomic) IBOutlet UILabel *authorLabel;
@property (retain, nonatomic) IBOutlet UIButton *selectButton;

- (void)setCellData:(PBSong *)song;

@end
