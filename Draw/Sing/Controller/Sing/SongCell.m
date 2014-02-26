//
//  SongCell.m
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import "SongCell.h"
#import "AutoCreateViewByXib.h"

@interface SongCell ()

@property (retain, nonatomic) PBSong *song;

@end

@implementation SongCell

AUTO_CREATE_VIEW_BY_XIB(SongCell);

- (void)dealloc {
    [_nameLabel release];
    [_authorLabel release];
    [_selectButton release];
    [_song release];
    [super dealloc];
}

+ (NSString*)getCellIdentifier{
    return @"SongCell";
}

+ (CGFloat)getCellHeight{
    return (ISIPAD ? 129 : 60);
}

- (void)setCellData:(PBSong *)song{
    self.nameLabel.text = song.name;
    self.authorLabel.text = song.author;
    
    self.nameLabel.textColor = COLOR_BROWN;
    self.authorLabel.textColor = COLOR_GREEN;
    
    SET_BUTTON_ROUND_STYLE_ORANGE(self.selectButton);
    
    self.song = song;
    
    [self bringSubviewToFront:self.selectButton];
}

- (IBAction)clickSelectButton:(id)sender {
    
    if ([delegate respondsToSelector:@selector(didSelectSong:)]) {
        
        [(id<SongCellDelegate>)delegate didSelectSong:self.song];
    }
}



@end
