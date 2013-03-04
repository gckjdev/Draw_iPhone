//
//  StoreCell.m
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "StoreCell.h"

@implementation StoreCell

+ (NSString *)getCellIdentifier
{
    return @"StoreCell";
}

+ (CGFloat)getCellHeight
{
    return 80;
}

- (void)setCellInfo:(PBGameItem *)item
{
    
}


- (void)dealloc {
    [_itemImageView release];
    [_itemNameLabel release];
    [_itemDescLabel release];
    [super dealloc];
}
@end
