//
//  BulletinCell.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinCell.h"
#import "Bulletin.h"
#import "AutoCreateViewByXib.h"
#import "GameApp.h"

@implementation BulletinCell

AUTO_CREATE_VIEW_BY_XIB(BulletinCell)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initView
{
    [self.backgroundImageView setImage:[[GameApp getImageManager] bulletinBackgroundImage]];
    [self setAccessoryView:[[[UIImageView alloc] initWithImage:[[GameApp getImageManager] bulletinAccessoryImage]] autorelease]];
}

+ (NSString*)getCellIdentifier
{
    return @"BulletinCell";
}

+ (BulletinCell*)createCell:(id)delegate
{
    return (BulletinCell*)[BulletinCell createView];
}

+ (float)getCellHeight
{
    return 75;
}

- (void)setCellByBulletin:(Bulletin *)bulletin
{
    [self initView];
    
    [self.messageLabel setText:bulletin.message];
}

- (void)dealloc {
    [_messageLabel release];
    [_backgroundImageView release];
    [_contentLabel release];
    [_dateBgView release];
    [_timeButton release];
    [_dateLabel release];
    [super dealloc];
}
@end
