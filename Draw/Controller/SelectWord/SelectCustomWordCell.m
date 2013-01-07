//
//  SelectCustomWordCell.m
//  Draw
//
//  Created by 王 小涛 on 13-1-7.
//
//

#import "SelectCustomWordCell.h"

@implementation SelectCustomWordCell

+ (CGFloat)getCellHeight
{
    return 45 * ([DeviceDetection isIPAD] ? 2 : 1);
}

+ (NSString *)getCellIdentifier
{
    return @"SelectCustomWordCell" ;
}


- (void)setWord:(NSString *)word
{
    PPDebug(@"des: %@", self.wordLabel.description);
    self.wordLabel.text = word;
}


- (void)dealloc {
    [_wordLabel release];
    [super dealloc];
}
@end
