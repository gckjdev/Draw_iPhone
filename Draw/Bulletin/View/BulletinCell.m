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

@implementation BulletinCell

AUTO_CREATE_VIEW_BY_XIB(Bulletin)

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

+ (NSString*)getCellIdentifier
{
    return @"BulletinCell";
}

+ (BulletinCell*)createCell:(id)delegate
{
    return (BulletinCell*)[BulletinCell createView];
}

- (void)setCellByBulletin:(Bulletin *)bulletin
{
    [self.messageLabel setText:bulletin.message];
}

- (void)dealloc {
    [_messageLabel release];
    [super dealloc];
}
@end
