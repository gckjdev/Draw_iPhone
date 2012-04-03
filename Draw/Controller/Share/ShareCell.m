//
//  ShareCell.m
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareCell.h"

@implementation ShareCell
@synthesize leftButton;
@synthesize middleButton;
@synthesize rightButton;

+ (ShareCell*)creatShareCell
{
    ShareCell* cell = [[[ShareCell alloc] init] autorelease];
    return cell;
}

+ (NSString*)getIdentifier
{
    return @"ShareCell";
}

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

- (void)dealloc {
    [leftButton release];
    [middleButton release];
    [rightButton release];
    [super dealloc];
}
@end
