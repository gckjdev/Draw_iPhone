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
@property (retain, nonatomic) IBOutlet UILabel *costCoinLabel;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;


- (void)setCellData:(PBSong *)song forIndex:(NSIndexPath *)index;
@end
