//
//  SongCell.m
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import "SongCell.h"
#import "AutoCreateViewByXib.h"

#define COLOR1 ([UIColor colorWithRed:159/255.0 green:56/255.0 blue:14/255.0 alpha:1])
#define COLOR2 ([UIColor colorWithRed:13/255.0 green:103/255.0 blue:88/255.0 alpha:1])
#define COLOR3 ([UIColor colorWithRed:31/255.0 green:1/255.0 blue:69/255.0 alpha:1])
#define COLOR4 ([UIColor colorWithRed:122/255.0 green:12/255.0 blue:34/255.0 alpha:1])
#define COLOR5 ([UIColor colorWithRed:53/255.0 green:24/255.0 blue:2/255.0 alpha:1])


@implementation SongCell

AUTO_CREATE_VIEW_BY_XIB(SongCell);

+ (NSString*)getCellIdentifier{
    return @"SongCell";
}

+ (CGFloat)getCellHeight{
    return 60;
    
}

- (void)setCellData:(PBSong *)song forIndex:(NSIndexPath *)index{
    self.nameLabel.text = song.name;
    self.authorLabel.text = song.author;
    [self setWithRow:index.row];
}

- (void)setWithRow:(int)row{
    switch (row) {
        case 0:
            self.costCoinLabel.textColor = COLOR1;
            self.bgImageView.image = [UIImage imageNamed:@"song_bg1@2x.png"];
            break;
            
        case 1:
            self.costCoinLabel.textColor = COLOR2;
            self.bgImageView.image = [UIImage imageNamed:@"song_bg2@2x.png"];
            break;
            
        case 2:
            self.costCoinLabel.textColor = COLOR3;
            self.bgImageView.image = [UIImage imageNamed:@"song_bg3@2x.png"];
            break;
            
        case 3:
            self.costCoinLabel.textColor = COLOR4;
            self.bgImageView.image = [UIImage imageNamed:@"song_bg4@2x.png"];
            break;
            
        case 4:
            self.costCoinLabel.textColor = COLOR5;
            self.bgImageView.image = [UIImage imageNamed:@"song_bg5@2x.png"];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    [_nameLabel release];
    [_costCoinLabel release];
    [_authorLabel release];
    [_bgImageView release];
    [super dealloc];
}

@end
