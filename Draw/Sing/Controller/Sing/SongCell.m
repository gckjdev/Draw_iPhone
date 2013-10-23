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
    return (ISIPAD ? 132 : 60);
}

- (void)setCellData:(PBSong *)song{
    self.nameLabel.text = song.name;
    self.authorLabel.text = song.author;
    self.song = song;
}

- (IBAction)clickSelectButton:(id)sender {
    
    if ([delegate respondsToSelector:@selector(didSelectSong:)]) {
        
        [delegate didSelectSong:self.song];
    }
}



@end
