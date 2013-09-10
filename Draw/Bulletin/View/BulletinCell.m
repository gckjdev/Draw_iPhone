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
#import "UILabel+Extend.h"

#define TOTAL_SEPERATOR ([DeviceDetection isIPAD]?80:40)
#define MAX_CONTENT_LABEL_HEIGHT  ([DeviceDetection isIPAD]?900:450)
#define CONTENT_FONT_SIZE   ([DeviceDetection isIPAD]?26:13)
#define CONTENT_LABEL_WIDTH ([DeviceDetection isIPAD]?426:205)

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
                                         lineBreakMode:UILineBreakModeTailTruncation];

    return CGSizeMake(size.width, size.height + TOTAL_SEPERATOR);
}

//- (void)resize
//{
//    CGSize size = [BulletinCell cellSizeForContent:self.messageLabel.text];
//    
//    [self.messageLabel updateHeight:(size.height - TOTAL_SEPERATOR)];
//        
//    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height)];
//}

- (void)initView
{
    [self setAccessoryType:UITableViewCellAccessoryNone];
    [self.customAccessoryImageView setImage:[[GameApp getImageManager] bulletinAccessoryImage]];
//    [self resize];
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
    PPDebug(@"bulletin: %@", bulletin.message);
    [self.messageLabel setText:bulletin.message];
    
    CGFloat oldHeight = self.messageLabel.frame.size.height;
    CGSize constrainedSize = CGSizeMake(self.messageLabel.frame.size.width, MAX_CONTENT_LABEL_HEIGHT);
    [self.messageLabel wrapTextWithConstrainedSize:constrainedSize];
    
    CGFloat delta = self.messageLabel.frame.size.height - oldHeight;
    [self.contentHolderView updateHeight:(self.contentHolderView.frame.size.height + delta)];
    
    SET_VIEW_ROUND_CORNER(self.contentHolderView);
    self.contentHolderView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.contentHolderView.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.newBulletinFlag setHidden:bulletin.hasRead];

    NSString *str = [NSString stringWithFormat:@"%@  %@", dateToLocaleStringWithFormat(bulletin.date, @"yyyy.MM.dd"), dateToLocaleStringWithFormat(bulletin.date, @"HH:mm")];
    [self.dateLabel setText:str];
    
    self.dateLabel.textColor = COLOR_GREEN;
    self.messageLabel.textColor = COLOR_BROWN;

    [self.customAccessoryImageView setHidden:!([JumpHandler canJump:bulletin.type])];
    [self initView];
}

- (void)dealloc {
    [_messageLabel release];
    [_dateLabel release];
    [_newBulletinFlag release];
    [_customAccessoryImageView release];
    [_contentHolderView release];
    [super dealloc];
}
@end
