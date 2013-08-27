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
#import "TimeUtils.h"
#import "JumpHandler.h"

#define TOTAL_SEPERATOR ([DeviceDetection isIPAD]?90:45)
#define MAX_CONTENT_LABEL_HEIGHT    ([DeviceDetection isIPAD]?900:450)
#define CONTENT_FONT_SIZE   ([DeviceDetection isIPAD]?26:13)
#define CONTENT_LABEL_WIDTH ([DeviceDetection isIPAD]?330:165)

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

+ (CGSize)cellSizeForContent:(NSString *)content
{
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]
                                     constrainedToSize:CGSizeMake(CONTENT_LABEL_WIDTH, MAX_CONTENT_LABEL_HEIGHT)
                                         lineBreakMode:UILineBreakModeWordWrap];
    return CGSizeMake(size.width, size.height + TOTAL_SEPERATOR);
}

- (void)resize
{
    CGSize size = [BulletinCell cellSizeForContent:self.contentLabel.text];

    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height)];
}

- (void)initView
{
    
    [self.backgroundImageView setImage:[[GameApp getImageManager] bulletinBackgroundImage]];
//    [self setAccessoryView:[[[UIImageView alloc] initWithImage:[[GameApp getImageManager] bulletinAccessoryImage]] autorelease]];
    [self setAccessoryType:UITableViewCellAccessoryNone];
    [self.customAccessoryImageView setImage:[[GameApp getImageManager] bulletinAccessoryImage]];
    [self resize];
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
    return (ISIPAD ? 175 : 84);
}

- (void)setCellByBulletin:(Bulletin *)bulletin
{
    [self.messageLabel setText:bulletin.message];
    [self.newBulletinFlag setHidden:bulletin.hasRead];

    NSString *str = [NSString stringWithFormat:@"%@  %@", dateToLocaleStringWithFormat(bulletin.date, @"yyyy.MM.dd"), dateToLocaleStringWithFormat(bulletin.date, @"HH:mm")];
    [self.dateLabel setText:str];
    
    self.dateLabel.textColor = COLOR_ORANGE;
    self.messageLabel.textColor = COLOR_BROWN;
    
    [self.customAccessoryImageView setHidden:!([JumpHandler canJump:bulletin.type])];
    [self initView];
}

- (void)dealloc {
    [_messageLabel release];
    [_backgroundImageView release];
    [_contentLabel release];
    [_dateBgView release];
    [_timeButton release];
    [_dateLabel release];
    [_newBulletinFlag release];
    [_customAccessoryImageView release];
    [super dealloc];
}
@end
